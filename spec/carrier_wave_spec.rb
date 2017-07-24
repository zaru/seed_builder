require "spec_helper"

RSpec.describe SeedBuilder::Upload::CarrierWave do

  before do
    ModelGenerator::Reset.new.all
    if Object.const_defined? :IconUploader
      Object.send(:remove_const, :IconUploader)
    end
  end

  describe "carrierwave" do
    context "no validate" do
      it "should be set file object" do
        class IconUploader < CarrierWave::Uploader::Base
          storage :file
        end
        ModelGenerator::create_model(:users) do
          string :icon, null: false
          mount_uploader :icon, IconUploader
        end

        user = User.new
        upload = SeedBuilder::Upload::CarrierWave.new user, "icon"
        upload.value
        expect(user.icon.file.nil?).to be_falsey
      end
    end

    context "ext whitelist" do
      it "should be set file object" do
        class IconUploader < CarrierWave::Uploader::Base
          storage :file

          def extension_whitelist
            %w(gif png)
          end
        end
        ModelGenerator::create_model(:users) do
          string :icon, null: false
          mount_uploader :icon, IconUploader
        end

        user = User.new
        upload = SeedBuilder::Upload::CarrierWave.new user, "icon"
        upload.value
        expect(user.icon.file.nil?).to be_falsey
      end
    end

    context "content_type whitelist" do
      it "should be set file object" do
        class IconUploader < CarrierWave::Uploader::Base
          storage :file

          def content_type_whitelist
            /image\/png/
          end
        end
        ModelGenerator::create_model(:users) do
          string :icon, null: false
          mount_uploader :icon, IconUploader
        end

        user = User.new
        upload = SeedBuilder::Upload::CarrierWave.new user, "icon"
        upload.value
        expect(user.icon.file.nil?).to be_falsey
      end
    end
  end
end
