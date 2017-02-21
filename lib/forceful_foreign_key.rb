require "forceful_foreign_key/version"
require "forceful_foreign_key/graph"

module ActiveRecord::ConnectionAdapters::SchemaStatements
  alias_method :old_add_foreign_key, :add_foreign_key

  def add_foreign_key(from_table, to_table, options = {})
    return unless supports_foreign_keys?
    if options[:force]
      graph = ForcefulForeignKey::Graph.new
      graph.build_graph
      graph.delete_orphans(from_table: from_table,
                           from_column: options[:column] || "#{to_table}_id",
                           target_table: to_table,
                           target_column: options[:primary_key] || 'id')
    end
    old_add_foreign_key from_table, to_table, options
  end
end
