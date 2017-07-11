require "spec_helper"

RSpec.describe SeedBuilder::EntityBase do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "auto_create" do
    it "should be save data of string type" do
      ModelGenerator::create_model(:users) do
        string :name, null: false
        validates :name, presence: true, uniqueness: true, length: { in: 6..20 }
      end

      expect(User.auto_create).to be_truthy
      expect(User.all.size).to eq 1
    end

    it "should be save data of numeric type" do
      ModelGenerator::create_model(:users) do
        integer :name, null: false
        validates :name, numericality: true
      end

      expect(User.auto_create).to be_truthy
      expect(User.all.size).to eq 1
    end

    # TODO: add other condition test case
  end

  describe "foreign_keys" do

    context "normal association" do
      it "should eq included reference key and classes" do
        ModelGenerator::create_model(:users) do
          has_many :books
        end
        ModelGenerator::create_model(:books) do
          references :user
          belongs_to :user
        end

        expect(Book.foreign_keys).to match [
                                             a_hash_including( foreign_key: "user_id", klass: User )
                                           ]
        expect(User.foreign_keys).to be_empty
      end
    end

    context "has_many through" do
      it "should eq included reference key and classes" do
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
        expect(Appointment.foreign_keys).to match [
                                             a_hash_including( foreign_key: "physician_id", klass: Physician ),
                                             a_hash_including( foreign_key: "patient_id", klass: Patient )
                                           ]
        expect(Physician.foreign_keys).to be_empty
        expect(Patient.foreign_keys).to be_empty
      end
    end

    context "polymorphic" do
      it "should be not included reference key and classes" do
        ModelGenerator::create_model(:books) do
          string :name, null: false

          has_many :reviews, as: :messagable
        end

        ModelGenerator::create_model(:reviews) do
          string :comment, null: false
          references :messagable, polymorphic: true
          belongs_to :messagable, polymorphic: true
        end

        expect(Review.foreign_keys).to be_empty
      end
    end

  end

  describe "polymorphic_columns" do
    context "polymorphic" do
      it "should be included polymorphic type and foreign key" do
        ModelGenerator::create_model(:books) do
          string :name, null: false

          has_many :reviews, as: :messagable
        end

        ModelGenerator::create_model(:reviews) do
          string :comment, null: false
          references :messagable, polymorphic: true
          belongs_to :messagable, polymorphic: true
        end

        expect(Review.polymorphic_columns).to match [
                                                      a_hash_including( type: "messagable", foreign_key: "messagable_id")
                                                    ]
      end
    end
  end

  describe "attribute_collection" do
    it "should be included SeedBuilder::Attribute object" do
      ModelGenerator::create_model(:users) do
        string :name
      end

      expect(User.new.attribute_collection).to be_all {|obj| obj.is_a? SeedBuilder::Attribute }
    end
  end

  describe "method_missing" do
    it "should be call SeedBuilder::Attribute object with field name" do
      ModelGenerator::create_model(:users) do
        string :name
      end

      expect(User.new.attribute_collection.id).to be_a SeedBuilder::Attribute
      expect(User.new.attribute_collection.name).to be_a SeedBuilder::Attribute
      expect(User.new.attribute_collection.created_at).to be_a SeedBuilder::Attribute
      expect(User.new.attribute_collection.updated_at).to be_a SeedBuilder::Attribute
    end
  end
end
