require "spec_helper"

RSpec.describe SeedBuilder::ValidData do

  before do
    ModelGenerator::Reset.new.all
  end

  describe "generate" do

    let (:stub_text) { "stub message" }

    context "String or Text" do

      let (:mock) { SeedBuilder::Valid::String.new model_object: "", key: "" }

      before do
        allow(SeedBuilder::Valid::String).to receive(:new).and_return(mock)
        allow(mock).to receive(:generate).and_return(stub_text)
      end

      it "should be call generate of Valid::String when String" do
        valid_data = SeedBuilder::ValidData.new type_name: "String", model_object: nil, key: nil
        valid_data.generate
        expect(mock).to have_received(:generate).once
      end

      it "should be call generate of Valid::String when Text" do
        valid_data = SeedBuilder::ValidData.new type_name: "Text", model_object: nil, key: nil
        valid_data.generate
        expect(mock).to have_received(:generate).once
      end
    end

    context "Integer or BigInteger or Decimal" do

      let (:mock) { SeedBuilder::Valid::Integer.new model_object: "", key: "" }

      before do
        allow(SeedBuilder::Valid::Integer).to receive(:new).and_return(mock)
        allow(mock).to receive(:generate).and_return(stub_text)
      end

      it "should be call generate of Valid::Integer when Integer" do
        valid_data = SeedBuilder::ValidData.new type_name: "Integer", model_object: nil, key: nil
        valid_data.generate
        expect(mock).to have_received(:generate).once
      end

      it "should be call generate of Valid::Integer when BigInteger" do
        valid_data = SeedBuilder::ValidData.new type_name: "BigInteger", model_object: nil, key: nil
        valid_data.generate
        expect(mock).to have_received(:generate).once
      end

      it "should be call generate of Valid::Integer when Decimal" do
        valid_data = SeedBuilder::ValidData.new type_name: "Decimal", model_object: nil, key: nil
        valid_data.generate
        expect(mock).to have_received(:generate).once
      end
    end

    context "ETC type" do

      types = %w(Binary Boolean Date Datetime Time)
      types.each do |type|
        let (:mock) { Object.const_get("SeedBuilder::Type::#{type}").new }

        before do
          allow(Object.const_get("SeedBuilder::Type::#{type}")).to receive(:new).and_return(mock)
          allow(mock).to receive(:generate).and_return(stub_text)
        end

        it "should be call generate of Type::#{type} when #{type}" do
          valid_data = SeedBuilder::ValidData.new type_name: type, model_object: nil, key: nil
          valid_data.generate
          expect(mock).to have_received(:generate).once
        end
      end

    end


  end
end
