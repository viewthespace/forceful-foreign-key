$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'active_record'
require 'pry'
require "forceful_foreign_key"
require 'database_cleaner'

`createdb forceful_foreign_key_test`
`createuser -s forceful_foreign_key_test`

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :username => "forceful_foreign_key_test",
  :password => "",
  :database => "forceful_foreign_key_test"
)

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end