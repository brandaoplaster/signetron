# frozen_string_literal: true

module Signetron
  module Models
    # Base model class with automatic validation
    #
    # Provides basic validation, attribute manipulation and error handling
    # functionality for all application models using dry-validation contracts
    #
    # @example Basic usage (requires inheritance)
    #   class User < Signetron::Models::Base
    #     private
    #
    #     def validator
    #       @validator ||= UserContract.new
    #     end
    #   end
    #
    #   user = User.new(name: "John", email: "john@example.com")
    #
    class Base
      attr_reader :attributes, :errors

      # Initializes the model with automatic validation
      #
      # @param attributes [Hash] model attributes to be validated
      #
      # @raise [ValidationError] when validation fails during initialization
      #
      # @example Creating a valid model
      #   user = User.new(name: "John", email: "john@example.com")
      #
      # @example Handling validation errors
      #   begin
      #     user = User.new(name: "", email: "invalid")
      #   rescue ValidationError => e
      #     puts e.message
      #     puts e.errors
      #   end
      #
      def initialize(attributes = {})
        @attributes = {}
        @errors = []
        normalized_attrs = normalize_keys(attributes)
        result = validator.call(normalized_attrs)

        if result.success?
          @attributes = result.to_h
        else
          @errors = format_dry_errors(result.errors)
          raise ValidationError.new(format_error_messages, @errors)
        end
      end

      # Checks if the model is valid
      #
      # @return [Boolean] true if there are no validation errors
      #
      # @example
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.valid? # => true
      #
      def valid?
        @errors.empty?
      end

      # Checks if the model is invalid
      #
      # @return [Boolean] true if there are validation errors
      #
      # @example
      #   user.invalid? # => false
      #
      def invalid?
        !valid?
      end

      # Returns a copy of the validated attributes
      #
      # @return [Hash] duplicate of the attributes hash
      #
      # @example
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.to_h # => { name: "John", email: "john@example.com" }
      #
      def to_h
        @attributes.dup
      end

      # Returns validation errors grouped by field
      #
      # @return [Hash] hash with field names as keys and arrays of error messages as values
      #
      # @example
      #   user.errors_hash # => { name: ["can't be blank"], email: ["is invalid"] }
      #
      def errors_hash
        @errors.each_with_object({}) do |error, hash|
          field = error[:field]
          hash[field] ||= []
          hash[field] << error[:message]
        end
      end

      # Updates model attributes with validation
      #
      # @param new_attributes [Hash] new attributes to merge with existing ones
      #
      # @return [Boolean] true if validation passes, false otherwise
      #
      # @example Successful update
      #   user.update_attributes?(email: "newemail@example.com") # => true
      #
      # @example Failed update
      #   user.update_attributes?(email: "invalid") # => false
      #   user.errors # => [{ field: :email, message: "is invalid" }]
      #
      def update_attributes?(new_attributes)
        merged_attrs = @attributes.merge(normalize_keys(new_attributes))
        result = validator.call(merged_attrs)

        if result.success?
          @attributes = result.to_h
          @errors = []
          true
        else
          @errors = format_dry_errors(result.errors)
          false
        end
      end

      private

      # Normalizes attribute keys to symbols
      #
      # @param attributes [Hash, Object] attributes to normalize
      # @return [Hash] hash with symbolized keys or empty hash
      #
      def normalize_keys(attributes)
        case attributes
        when Hash
          attributes.transform_keys(&:to_sym)
        else
          {}
        end
      end

      # Abstract method that must be implemented by subclasses
      #
      # @raise [NotImplementedError] when not implemented in subclass
      # @return [Object] dry-validation contract instance
      #
      def validator
        raise NotImplementedError, "Subclasses must implement #validator method"
      end

      # Formats dry-validation errors to internal format
      #
      # @param dry_errors [Array] errors from dry-validation
      # @return [Array<Hash>] formatted errors with :field and :message keys
      #
      def format_dry_errors(dry_errors)
        dry_errors.map do |error|
          {
            field: error.path.join(".").to_sym,
            message: error.text,
          }
        end
      end

      # Formats error messages for exception
      #
      # @return [String] comma-separated error messages
      #
      def format_error_messages
        @errors.map { |error| "#{error[:field]}: #{error[:message]}" }.join(", ")
      end
    end

    # Custom exception for validation errors
    #
    # Raised when model validation fails during initialization
    #
    class ValidationError < StandardError
      attr_reader :errors

      # Initializes validation error with message and error details
      #
      # @param message [String] formatted error message
      # @param errors [Array<Hash>] array of error hashes with field and message
      #
      def initialize(message, errors = [])
        super(message)
        @errors = errors
      end
    end
  end
end
