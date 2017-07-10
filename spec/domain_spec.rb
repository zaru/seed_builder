require "spec_helper"

RSpec.describe SeedBuilder do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "entities" do

    subject { SeedBuilder::Domain.new.entities }

    it "should eq included model classes" do
      ModelGenerator::create_model(:books) do; end

      is_expected.to include Book
    end

    it "should not be included STI base class" do
      ModelGenerator::create_model(:books) do
        string :type, null: false
      end
      ModelGenerator::create_model(:game_books, :books) do; end
      ModelGenerator::create_model(:music_books, :books) do; end

      is_expected.to include GameBook, MusicBook
      is_expected.to_not include Book
    end

    it "should not be included abstract class" do
      ModelGenerator::create_model(:books) do; end
      Book.abstract_class = true

      is_expected.to_not include Book
    end

    it "should not be included one side of the intermediate table of HABTM" do
      ModelGenerator::create_model(:books) do
        has_and_belongs_to_many :users
      end
      ModelGenerator::create_model(:users) do
        has_and_belongs_to_many :books
      end
      ModelGenerator::create_table(:books_users) do
        references :book, index: true, null: false
        references :user, index: true, null: false
      end

      is_expected.to include Book, User, Object.const_get("Book::HABTM_Users")
      is_expected.not_to include Object.const_get("User::HABTM_Books")
    end
  end
end
