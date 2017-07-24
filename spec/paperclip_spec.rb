require "spec_helper"

RSpec.describe SeedBuilder::Upload::Paperclip do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "paperclip" do
    it "should be set file object" do
      ModelGenerator::create_model(:users) do
        attachment :icon
        has_attached_file :icon,
                          styles: { medium: "300x300>", thumb: "100x100>" },
                          path: "uploads/tmp/:class/:id/:attachment/:style.:extension"
        validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/
      end

      user = User.new
      upload = SeedBuilder::Upload::Paperclip.new user, "icon"
      upload.value
      expect(user.icon.file?).to be_truthy
    end
  end
end
