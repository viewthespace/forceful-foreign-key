module ForcefulForeignKey
  class Graph

    attr_reader :graph
    attr_reader :dry_run

    def initialize dry_run: false
      @dry_run = dry_run
      init_dep_graph
      build_graph
    end

    def delete_orphans(from_table:, from_column:, target_table:, target_column:, parent_ids: [])
      limit = 1_000
      offset = 0
      if parent_ids.empty?
        sql = "select distinct #{from_table}.id from #{from_table} left outer join #{target_table} on #{target_table}.#{target_column} = #{from_table}.#{from_column} where #{from_table}.#{from_column} is not null and #{target_table}.#{target_column} is null"
      else
        sql = "select distinct #{from_table}.id from #{from_table} left outer join #{target_table} on #{target_table}.#{target_column} = #{from_table}.#{from_column} where #{target_table}.#{target_column} in(#{parent_ids.join(',')})"
      end
      sql += " limit #{limit} offset 0"
      loop do
        ids = ActiveRecord::Base.connection.execute(sql).map{ |r| r['id'] }
        break if ids.empty?
        if dry_run
          sql.gsub!(/\d+/, (offset += limit).to_s)
        end
        graph[from_table][:edges].each do |edge|
          delete_orphans(from_table: edge[:table], from_column: edge[:column], target_table: from_table, target_column: 'id', parent_ids: ids)
        end
        delete_sql = "delete from #{from_table} where id in (#{ids.join(',')})"
        puts delete_sql
        select_sql = "select *  from #{from_table} where id in (#{ids.join(',')})"
        r = ActiveRecord::Base.connection.execute(select_sql).to_a
        unless dry_run
          ActiveRecord::Base.connection.execute(delete_sql)
        end
      end
    end

    def init_dep_graph
      @graph = tables.each_with_object({}){ |tables, graph| graph[tables] = { edges: [] } }
    end

    def build_graph
      init_dep_graph
      graph.each do |table, obj|
        fks.select{ |fk| fk['references_table'] == table }.each do |fk|
          obj[:edges].push({table: fk['table_name'], column: fk['column_name'] })
        end
      end
    end

    def fks
      ActiveRecord::Base.connection.execute(
          <<-SQL
          SELECT tc.table_name,
          kcu.constraint_name,
          kcu.column_name,
          ccu.table_name AS references_table,
          ccu.column_name AS references_field
          FROM information_schema.table_constraints tc
  
          LEFT JOIN information_schema.key_column_usage kcu
          ON tc.constraint_catalog = kcu.constraint_catalog
          AND tc.constraint_schema = kcu.constraint_schema
          AND tc.constraint_name = kcu.constraint_name
  
          LEFT JOIN information_schema.referential_constraints rc
          ON tc.constraint_catalog = rc.constraint_catalog
          AND tc.constraint_schema = rc.constraint_schema
          AND tc.constraint_name = rc.constraint_name
  
          LEFT JOIN information_schema.constraint_column_usage ccu
          ON rc.unique_constraint_catalog = ccu.constraint_catalog
          AND rc.unique_constraint_schema = ccu.constraint_schema
          AND rc.unique_constraint_name = ccu.constraint_name
          WHERE lower(tc.constraint_type) in ('foreign key')
      SQL
      ).to_a
    end

    def tables
      ActiveRecord::Base.connection.execute(
          <<-SQL
          SELECT * FROM information_schema.tables
          WHERE table_schema = 'public'
      SQL
      ).to_a.map{ |r| r['table_name'] }
    end

  end
end