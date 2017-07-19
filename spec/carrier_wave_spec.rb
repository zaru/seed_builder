require "spec_helper"

RSpec.describe SeedBuilder::Upload::CarrierWave do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "carrierwave" do
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
end
