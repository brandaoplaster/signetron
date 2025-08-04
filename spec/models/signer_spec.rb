# frozen_string_literal: true

require "spec_helper"

RSpec.describe Signetron::Models::Signer do
  # Valid signer data that passes all validations (without communicate_events)
  let(:valid_signer_attributes) do
    {
      name: "John Doe Smith",
      email: "john@example.com",
      phone_number: "+1234567890",
      has_documentation: true,
      documentation: "123.456.789-00",
      birthday: Date.new(1990, 5, 15),
      refusable: true,
      group: 1,
      location_required_enabled: false
    }
  end

  # Minimal valid signer data (only required fields)
  let(:minimal_valid_attributes) do
    {
      name: "Jane Doe"
    }
  end

  describe "#initialize" do
    context "with valid attributes" do
      it "creates a signer with complete data" do
        signer = described_class.new(valid_signer_attributes)

        expect(signer.name).to eq("John Doe Smith")
        expect(signer.email).to eq("john@example.com")
        expect(signer.phone_number).to eq("+1234567890")
        expect(signer.documentation_required?).to be true
        expect(signer.documentation).to eq("123.456.789-00")
        expect(signer.birthday).to eq(Date.new(1990, 5, 15))
        expect(signer.refusable).to be true
        expect(signer.group).to eq(1)
        expect(signer.location_required_enabled).to be false
      end

      it "creates a signer with minimal required data" do
        signer = described_class.new(minimal_valid_attributes)

        expect(signer.name).to eq("Jane Doe")
        expect(signer.email).to be_nil
        expect(signer.phone_number).to be_nil
        expect(signer.documentation_required?).to be_nil
      end
    end

    context "with invalid attributes" do
      it "raises ValidationError when name is missing" do
        expect {
          described_class.new(email: "test@example.com")
        }.to raise_error(Signetron::Models::ValidationError) do |error|
          expect(error.message).to include("name")
        end
      end

      it "raises ValidationError for invalid name format" do
        expect {
          described_class.new(name: "John") # Only first name
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for name with numbers" do
        expect {
          described_class.new(name: "John Doe 123")
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for invalid email format" do
        expect {
          described_class.new(
            name: "John Doe",
            email: "invalid-email"
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for invalid phone format" do
        expect {
          described_class.new(
            name: "John Doe",
            phone_number: "123"
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for invalid documentation format" do
        expect {
          described_class.new(
            name: "John Doe",
            has_documentation: true,
            documentation: "invalid-cpf"
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for underage birthday" do
        underage_date = Date.today - (10 * 365) # Aproximadamente 10 anos atrás
        expect {
          described_class.new(
            name: "John Doe",
            has_documentation: true,
            birthday: underage_date
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for negative group number" do
        expect {
          described_class.new(
            name: "John Doe",
            group: -1
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end
    end
  end

  describe "attribute accessors" do
    let(:signer) { described_class.new(valid_signer_attributes) }

    describe "#name" do
      it "returns the signer's name" do
        expect(signer.name).to eq("John Doe Smith")
      end
    end

    describe "#email" do
      it "returns the signer's email" do
        expect(signer.email).to eq("john@example.com")
      end

      it "returns nil when email is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.email).to be_nil
      end
    end

    describe "#phone_number" do
      it "returns the signer's phone number" do
        expect(signer.phone_number).to eq("+1234567890")
      end

      it "returns nil when phone number is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.phone_number).to be_nil
      end
    end

    describe "#documentation_required?" do
      it "returns true when documentation is required" do
        expect(signer.documentation_required?).to be true
      end

      it "returns false when documentation is not required" do
        signer = described_class.new(
          name: "Jane Doe",
          has_documentation: false
        )
        expect(signer.documentation_required?).to be false
      end

      it "returns nil when not specified" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.documentation_required?).to be_nil
      end
    end

    describe "#documentation" do
      it "returns the CPF documentation" do
        expect(signer.documentation).to eq("123.456.789-00")
      end

      it "returns nil when documentation is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.documentation).to be_nil
      end
    end

    describe "#birthday" do
      it "returns the signer's birthday" do
        expect(signer.birthday).to eq(Date.new(1990, 5, 15))
      end

      it "returns nil when birthday is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.birthday).to be_nil
      end
    end

    describe "#refusable" do
      it "returns true when signer can refuse" do
        expect(signer.refusable).to be true
      end

      it "returns false when signer cannot refuse" do
        signer = described_class.new(
          name: "Jane Doe",
          refusable: false
        )
        expect(signer.refusable).to be false
      end

      it "returns nil when not specified" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.refusable).to be_nil
      end
    end

    describe "#group" do
      it "returns the group number" do
        expect(signer.group).to eq(1)
      end

      it "returns nil when group is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.group).to be_nil
      end
    end

    describe "#location_required_enabled" do
      it "returns the location requirement setting" do
        expect(signer.location_required_enabled).to be false
      end

      it "returns nil when not specified" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.location_required_enabled).to be_nil
      end
    end

    describe "#communicate_events" do
      it "returns nil when communicate_events is not set" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer.communicate_events).to be_nil
      end

      # Skip testing communicate_events functionality as CommunicateEventsValidator is not implemented
      # it "returns a CommunicateEvents instance when data is present" do
      #   # This test requires CommunicateEventsValidator to be implemented
      # end
    end
  end

  describe "#valid?" do
    context "with valid data" do
      it "returns true for complete valid signer" do
        signer = described_class.new(valid_signer_attributes)
        expect(signer).to be_valid
      end

      it "returns true for minimal valid signer" do
        signer = described_class.new(minimal_valid_attributes)
        expect(signer).to be_valid
      end

      it "returns true for signer without documentation requirement" do
        signer = described_class.new(
          name: "Jane Doe",
          email: "jane@example.com",
          has_documentation: false
        )
        expect(signer).to be_valid
      end

      it "returns true for signer with valid phone formats" do
        valid_phones = ["+1234567890", "1234567890", "(123) 456-7890", "123-456-7890"]
        
        valid_phones.each do |phone|
          signer = described_class.new(
            name: "John Doe",
            phone_number: phone
          )
          expect(signer).to be_valid, "Expected phone #{phone} to be valid"
        end
      end
    end
  end

  describe "#to_json_api" do
    context "with valid signer" do
      it "returns JSON API formatted data with all attributes" do
        signer = described_class.new(valid_signer_attributes)
        result = signer.to_json_api

        expect(result).to eq({
          data: {
            type: "signers",
            attributes: {
              name: "John Doe Smith",
              email: "john@example.com",
              phone_number: "+1234567890",
              has_documentation: true,
              documentation: "123.456.789-00",
              birthday: Date.new(1990, 5, 15),
              refusable: true,
              group: 1,
              location_required_enabled: false
            }
          }
        })
      end

      it "returns JSON API formatted data with minimal attributes" do
        signer = described_class.new(minimal_valid_attributes)
        result = signer.to_json_api

        expect(result).to eq({
          data: {
            type: "signers",
            attributes: {
              name: "Jane Doe"
            }
          }
        })
      end

      it "filters out nil values from attributes" do
        signer = described_class.new(
          name: "John Doe",
          email: "john@example.com",
          phone_number: nil,
          group: nil
        )
        result = signer.to_json_api

        expect(result[:data][:attributes]).to eq({
          name: "John Doe",
          email: "john@example.com"
        })
        expect(result[:data][:attributes]).not_to have_key(:phone_number)
        expect(result[:data][:attributes]).not_to have_key(:group)
      end
    end

    context "with invalid signer" do
      it "raises ValidationError for invalid signer data" do
        expect {
          described_class.new(name: "John") # Invalid: only first name
          .to_json_api
        }.to raise_error(Signetron::Models::ValidationError)
      end
    end
  end

  describe "validator integration" do
    let(:signer) { described_class.new(valid_signer_attributes) }

    it "uses SignerValidator internally" do
      validator = signer.send(:validator)
      expect(validator).to be_a(Signetron::Validators::SignerValidator)
    end

    it "validates using all SignerValidator rules" do
      # Test integration with various validator rules (excluding communicate_events)
      underage_date = Date.today - (10 * 365) # Aproximadamente 10 anos atrás
      expect {
        described_class.new(
          name: "John123", # Invalid: contains numbers
          email: "invalid-email", # Invalid: bad format
          phone_number: "123", # Invalid: too short
          has_documentation: true,
          documentation: "invalid", # Invalid: wrong format
          birthday: underage_date, # Invalid: underage
          group: -1 # Invalid: negative number
        )
      }.to raise_error(Signetron::Models::ValidationError)
    end
  end

  describe "edge cases and business rules" do
    # Skip communicate_events related tests as CommunicateEventsValidator is not implemented
    # it "validates email requirement when communicate_events uses email" do
    # it "validates phone requirement when communicate_events uses sms/whatsapp" do

    it "validates documentation dependency on has_documentation flag" do
      expect {
        described_class.new(
          name: "John Doe",
          has_documentation: false,
          documentation: "123.456.789-00" # Cannot send when has_documentation is false
        )
      }.to raise_error(Signetron::Models::ValidationError)
    end

    it "validates birthday dependency on has_documentation flag" do
      expect {
        described_class.new(
          name: "John Doe",
          has_documentation: false,
          birthday: Date.new(1990, 5, 15) # Cannot send when has_documentation is false
        )
      }.to raise_error(Signetron::Models::ValidationError)
    end

    it "accepts valid Brazilian CPF format" do
      valid_cpfs = ["123.456.789-00", "000.000.000-00", "999.999.999-99"]
      
      valid_cpfs.each do |cpf|
        signer = described_class.new(
          name: "John Doe",
          has_documentation: true,
          documentation: cpf
        )
        expect(signer).to be_valid, "Expected CPF #{cpf} to be valid"
      end
    end

    it "validates age boundaries correctly" do
      # Usa uma data específica que sabemos ser maior de 18 anos (25 anos atrás)
      valid_adult_birthday = Date.new(1999, 1, 1) # Nascido em 1999, definitivamente adulto
      signer = described_class.new(
        name: "John Doe",
        has_documentation: true,
        birthday: valid_adult_birthday
      )
      expect(signer).to be_valid

      # 121 anos atrás (boundary case - should be invalid)
      very_old_date = Date.new(1900, 1, 1) # Nascido em 1900, mais de 120 anos
      expect {
        described_class.new(
          name: "John Doe",
          has_documentation: true,
          birthday: very_old_date
        )
      }.to raise_error(Signetron::Models::ValidationError)
    end

    it "handles string birthday input" do
      signer = described_class.new(
        name: "John Doe",
        has_documentation: true,
        birthday: "1990-05-15"
      )
      # dry-validation pode converter string para Date automaticamente
      # Testamos se o valor foi definido (pode ser Date ou String dependendo da implementação)
      expect(signer.birthday).not_to be_nil
      expect([Date.new(1990, 5, 15), "1990-05-15"]).to include(signer.birthday)
    end

    it "validates name cannot be empty or whitespace only" do
      expect {
        described_class.new(name: "   ")
      }.to raise_error(Signetron::Models::ValidationError)
    end
  end

  describe "#filter_nil_values" do
    let(:signer) { described_class.new(minimal_valid_attributes) }

    it "removes nil values from hash" do
      hash_with_nils = {
        name: "John Doe",
        email: nil,
        phone_number: "123456789",
        group: nil
      }
      
      filtered = signer.send(:filter_nil_values, hash_with_nils)
      
      expect(filtered).to eq({
        name: "John Doe",
        phone_number: "123456789"
      })
    end

    it "preserves false values" do
      hash_with_false = {
        name: "John Doe",
        refusable: false,
        location_required_enabled: false,
        email: nil
      }
      
      filtered = signer.send(:filter_nil_values, hash_with_false)
      
      expect(filtered).to eq({
        name: "John Doe",
        refusable: false,
        location_required_enabled: false
      })
    end
  end
end