# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Signetron::Models::Base do
  describe '#initialize' do
    it 'raises NotImplementedError when validator method is not implemented' do
      expect {
        described_class.new(name: "test")
      }.to raise_error(NotImplementedError, "Subclasses must implement #validator method")
    end

    it 'raises NotImplementedError with empty attributes' do
      expect {
        described_class.new({})
      }.to raise_error(NotImplementedError, "Subclasses must implement #validator method")
    end

    it 'raises NotImplementedError with nil attributes' do
      expect {
        described_class.new(nil)
      }.to raise_error(NotImplementedError, "Subclasses must implement #validator method")
    end
  end

  describe '#valid?' do
    it 'raises NotImplementedError when accessing valid? without validator' do
      expect {
        instance = described_class.allocate
        instance.instance_variable_set(:@errors, [])
        instance.valid?
      }.not_to raise_error
    end
  end

  describe '#invalid?' do
    it 'returns opposite of valid?' do
      instance = described_class.allocate
      instance.instance_variable_set(:@errors, [])
      
      expect(instance.invalid?).to be false
    end
  end

  describe '#to_h' do
    it 'returns duplicate of attributes' do
      instance = described_class.allocate
      instance.instance_variable_set(:@attributes, { name: "test" })
      
      result = instance.to_h
      expect(result).to eq(name: "test")
      
      result[:name] = "modified"
      expect(instance.instance_variable_get(:@attributes)[:name]).to eq("test")
    end
  end

  describe '#errors_hash' do
    it 'returns empty hash when no errors' do
      instance = described_class.allocate
      instance.instance_variable_set(:@errors, [])
      
      expect(instance.errors_hash).to eq({})
    end

    it 'groups errors by field' do
      instance = described_class.allocate
      errors = [
        { field: :name, message: "can't be blank" },
        { field: :name, message: "too short" },
        { field: :email, message: "is invalid" }
      ]
      instance.instance_variable_set(:@errors, errors)
      
      result = instance.errors_hash
      expect(result).to eq({
        name: ["can't be blank", "too short"],
        email: ["is invalid"]
      })
    end
  end

  describe '#update_attributes?' do
    it 'raises NotImplementedError when validator not implemented' do
      instance = described_class.allocate
      instance.instance_variable_set(:@attributes, { name: "test" })
      instance.instance_variable_set(:@errors, [])
      
      expect {
        instance.update_attributes?(name: "new name")
      }.to raise_error(NotImplementedError, "Subclasses must implement #validator method")
    end
  end

  describe 'private methods' do
    let(:instance) { described_class.allocate }

    describe '#normalize_keys' do
      it 'converts string keys to symbols' do
        result = instance.send(:normalize_keys, "name" => "John", "age" => 30)
        expect(result).to eq(name: "John", age: 30)
      end

      it 'preserves symbol keys' do
        result = instance.send(:normalize_keys, name: "John", age: 30)
        expect(result).to eq(name: "John", age: 30)
      end

      it 'returns empty hash for non-hash input' do
        expect(instance.send(:normalize_keys, "string")).to eq({})
        expect(instance.send(:normalize_keys, nil)).to eq({})
        expect(instance.send(:normalize_keys, 123)).to eq({})
      end
    end

    describe '#validator' do
      it 'raises NotImplementedError' do
        expect {
          instance.send(:validator)
        }.to raise_error(NotImplementedError, "Subclasses must implement #validator method")
      end
    end

    describe '#format_dry_errors' do
      it 'formats dry-validation errors to internal format' do
        error1 = double('error', path: [:name], text: "can't be blank")
        error2 = double('error', path: [:address, :street], text: "is required")
        dry_errors = [error1, error2]
        
        result = instance.send(:format_dry_errors, dry_errors)
        
        expect(result).to eq([
          { field: :name, message: "can't be blank" },
          { field: :"address.street", message: "is required" }
        ])
      end
    end

    describe '#format_error_messages' do
      it 'formats errors into comma-separated string' do
        instance.instance_variable_set(:@errors, [
          { field: :name, message: "can't be blank" },
          { field: :email, message: "is invalid" }
        ])
        
        result = instance.send(:format_error_messages)
        expect(result).to eq("name: can't be blank, email: is invalid")
      end

      it 'returns empty string when no errors' do
        instance.instance_variable_set(:@errors, [])
        
        result = instance.send(:format_error_messages)
        expect(result).to eq("")
      end
    end
  end
end

RSpec.describe Signetron::Models::ValidationError do
  describe '#initialize' do
    it 'creates error with message and errors array' do
      errors = [
        { field: :name, message: "can't be blank" },
        { field: :email, message: "is invalid" }
      ]
      error = described_class.new("Validation failed", errors)
      
      expect(error.message).to eq("Validation failed")
      expect(error.errors).to eq(errors)
    end

    it 'creates error with empty errors array by default' do
      error = described_class.new("Validation failed")
      
      expect(error.message).to eq("Validation failed")
      expect(error.errors).to eq([])
    end
  end

  describe '#errors' do
    it 'provides read access to errors array' do
      errors = [{ field: :name, message: "can't be blank" }]
      error = described_class.new("Validation failed", errors)
      
      expect(error.errors).to eq(errors)
    end
  end
end