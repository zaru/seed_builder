require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class CreateAllTables < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:posts) do |t|
      t.text :content
      t.boolean :protected
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
