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

  describe "relationships" do

    subject { SeedBuilder::Domain.new.relationships }

    it "should be included has_many, belongs_to relationhip" do
      ModelGenerator::create_model(:books) do
        has_many :reviews
      end
      ModelGenerator::create_model(:reviews) do
        belongs_to :book
      end

      association = { src: Book, dst: Review, association: ActiveRecord::Reflection::HasManyReflection}
      is_expected.to include association
    end

    it "should be included has_one, belongs_to relationhip" do
      ModelGenerator::create_model(:books) do
        has_one :review
      end
      ModelGenerator::create_model(:reviews) do
        belongs_to :book
      end

      association = { src: Book, dst: Review, association: ActiveRecord::Reflection::HasOneReflection}
      is_expected.to include association
    end

    it "should be included has_many through relationhip" do
      ModelGenerator::create_model(:physicians) do
        has_many :appointments
        has_many :patients, through: :appointments
      end

      ModelGenerator::create_model(:appointments) do
        references :physician, index: true, null: false
        references :patient, index: true, null: false
        belongs_to :physician
        belongs_to :patient
      end

      ModelGenerator::create_model(:patients) do
        has_many :appointments
        has_many :physicians, through: :appointments
      end

      is_expected.to match [
                             a_hash_including( src: Physician, dst: Appointment, association: ActiveRecord::Reflection::HasManyReflection),
                             a_hash_including( src: Patient, dst: Appointment, association: ActiveRecord::Reflection::HasManyReflection)
                           ]
      is_expected.not_to match [
                             a_hash_including( src: Physician, dst: Patient, association: ActiveRecord::Reflection::HasManyReflection),
                             a_hash_including( src: Patient, dst: Physician, association: ActiveRecord::Reflection::HasManyReflection)
                           ]
    end


    it "should be included HABTM relationhip" do
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

      is_expected.to match [
                             a_hash_including( src: Book, dst: Object.const_get("Book::HABTM_Users"), association: ActiveRecord::Reflection::HasAndBelongsToManyReflection),
                             a_hash_including( src: User, dst: Object.const_get("Book::HABTM_Users"), association: ActiveRecord::Reflection::HasAndBelongsToManyReflection)
                           ]
    end

    it "should be included polymophic relationship" do
      ModelGenerator::create_model(:books) do
        string :name, null: false

        has_many :reviews, as: :messagable
      end
      ModelGenerator::create_model(:movies) do
        string :name, null: false

        has_many :reviews, as: :messagable
      end

      ModelGenerator::create_model(:reviews) do
        string :comment, null: false
        references :messagable, polymorphic: true
        belongs_to :messagable, polymorphic: true
      end

      is_expected.to match [
                             a_hash_including( src: Book, dst: Review, association: ActiveRecord::Reflection::HasManyReflection),
                             a_hash_including( src: Movie, dst: Review, association: ActiveRecord::Reflection::HasManyReflection)
                           ]
    end
  end
end
