require 'spec_helper'

describe ForcefulForeignKey do

  before do

    ActiveRecord::Base.connection.create_table('a')

    ActiveRecord::Base.connection.create_table('a_b') do |t|
      t.column :a_id, :integer
    end

    ActiveRecord::Base.connection.create_table('a_b_c') do |t|
      t.column :b_id, :integer
    end

    ActiveRecord::Base.connection.create_table('a_b_c_d') do |t|
      t.column :c_id, :integer
    end

    ActiveRecord::Base.connection.execute("INSERT INTO a values (1)")

    ActiveRecord::Base.connection.execute("INSERT INTO a_b values (1,1)")
    ActiveRecord::Base.connection.execute("INSERT INTO a_b values (2,2)") # Orphan
    ActiveRecord::Base.connection.execute("INSERT INTO a_b values (3,2)") # Orphan

    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c values (1,1)")
    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c values (2,2)")
    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c values (3,4)") # Orphan

    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c_d values (1,1)")
    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c_d values (2,2)")
    ActiveRecord::Base.connection.execute("INSERT INTO a_b_c_d values (3,5)") # Orphan

  end

  it 'is disabled by default' do

    expect do
      ActiveRecord::Base.connection.add_foreign_key 'a_b', 'a', force: false
    end.to raise_error(ActiveRecord::InvalidForeignKey)

  end

  it 'creates foreign key constraint when enabled' do

    ActiveRecord::Base.connection.add_foreign_key 'a_b', 'a', force: true

    expect(ActiveRecord::Base.connection.execute('select id from a where id = 1').ntuples).to eq(1)

    expect(ActiveRecord::Base.connection.execute('select id from a_b where id = 1').ntuples).to eq(1)
    expect(ActiveRecord::Base.connection.execute('select id from a_b where id = 2').ntuples).to eq(0)
    expect(ActiveRecord::Base.connection.execute('select id from a_b where id = 3').ntuples).to eq(0)

  end

end
