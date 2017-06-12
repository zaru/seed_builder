require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class CreateAllTables < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:users) do |t|
      t.string :name
    end

    create_table(:articles) do |t|
      t.string :title
      t.references :user
    end

    create_table(:comments) do |t|
      t.text :content
      t.references :articles
      t.references :user
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
