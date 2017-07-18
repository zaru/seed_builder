require "spec_helper"

RSpec.describe SeedBuilder::Attribute do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "build" do
    it "should be nil when primary key" do
      ModelGenerator::create_model(:users) do; end

      user = User.new
      user.attribute_collection.id.build
      expect(user.id).to be_nil
    end

    it "should be STI model name when STI type" do
      ModelGenerator::create_model(:accounts) do
        string :type, null: false
      end
      ModelGenerator::create_model(:users, :accounts) do; end

      user = User.new
      user.attribute_collection.type.build
      expect(user.type).to eq "User"
    end

    it "should be foreign id when foreign key" do
      ModelGenerator::create_model(:books) do
        has_many :reviews
      end
      ModelGenerator::create_model(:reviews) do
        references :book
        belongs_to :book
      end

      Book.auto_create
      review = Review.new
      review.attribute_collection.book_id.build
      expect(review.book_id).to eq Book.first.id
    end

    it "should be filename when carrier wave"

    context "string type" do
      it "should be valid data" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, presence: true, uniqueness: true, length: { in: 6..20 }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by regex" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, format: /\A(foo)[0-9]{1,4}[\-\/]{1}[a-z]{2}(baz)\z/
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by inclusion" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, inclusion: { in: %w(foo baz) }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by min length" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, length: { minimum: 2 }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by max length" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, length: { maximum: 2 }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by range length" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, length: { in: 6..20 }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end

      it "should be valid data by match length" do
        ModelGenerator::create_model(:users) do
          string :name, null: false
          validates :name, length: { is: 6 }
        end

        user = User.new
        user.attribute_collection.name.build
        expect(user.valid_attribute?(:name)).to be_truthy
      end
    end

    context "integer type" do
    end
    context "boolean type" do
    end
    context "date type" do
    end
    context "datetime type" do
    end
    context "decimal type" do
    end
    context "float type" do
    end
    context "text type" do
    end
    context "time type" do
    end
  end
end
