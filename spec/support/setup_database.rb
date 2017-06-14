require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

class CreateAllTables < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.timestamps
    end

    create_table(:articles) do |t|
      t.string :title
      t.references :user
      t.timestamps
    end

    create_table(:comments) do |t|
      t.text :content
      t.references :articles
      t.references :user
      t.timestamps
    end

    create_table(:companies) do |t|
      t.string :name
      t.timestamps
    end

    create_table(:messages) do |t|
      t.text :content
      t.references :messagable, polymorphic: true
      t.timestamps
    end

    create_table(:products) do |t|
      t.string :name
      t.string :type
      t.timestamps
    end

    create_table(:reviews) do |t|
      t.text :content
      t.references :product
      t.timestamps
    end

    create_table(:tags) do |t|
      t.string :name
      t.timestamps
    end

    create_table(:article_tags) do |t|
      t.references :article
      t.references :tag
      t.timestamps
    end

    create_table(:administrators) do |t|
      t.string :name
      t.timestamps
    end
    create_table(:roles) do |t|
      t.string :name
      t.timestamps
    end
    create_table(:administrators_roles) do |t|
      t.references :administrator
      t.references :role
      t.timestamps
    end
  end
end

# ActiveRecord::Migration.verbose = false
CreateAllTables.up
