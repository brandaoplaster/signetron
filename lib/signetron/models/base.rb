# frozen_string_literal: true

module Signetron
  module Models
    # Base model class with automatic validation using dry-validation
    #
    # Provides basic validation, attribute manipulation and error handling
    # functionality for all Signetron models. Uses dry-validation contracts
    # for robust data validation and standardized error reporting.
    #
    # All model classes should inherit from this base class and implement
    # the private validator method to define their validation rules.
    #
    # @abstract Subclass and implement {#validator} to create specific models
    # @author Signetron Team
    # @since 1.0.0
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
    #   user.valid? # => true
    #
    # @example Handling validation errors
    #   begin
    #     user = User.new(name: "", email: "invalid")
    #   rescue ValidationError => e
    #     puts e.message # => "name: can't be blank, email: is invalid"
    #     puts e.errors  # => [{ field: :name, message: "can't be blank" }, ...]
    #   end
    #
    class Base
      # @return [Hash] validated model attributes
      attr_reader :attributes

      # @return [Array<Hash>] validation errors with field and message keys
      attr_reader :errors

      # Initializes the model with automatic validation
      #
      # Validates the provided attributes using the model's validator contract.
      # If validation passes, attributes are stored and accessible. If validation
      # fails, raises ValidationError with detailed error information.
      #
      # @param attributes [Hash] model attributes to be validated
      # @option attributes [String] :name model name (example for envelope)
      # @option attributes [String] :locale language code (example for envelope)
      #
      # @raise [ValidationError] when validation fails during initialization
      # @raise [NotImplementedError] when validator method is not implemented
      #
      # @example Creating a valid model
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.attributes # => { name: "John", email: "john@example.com" }
      #
      # @example Validation error handling
      #   begin
      #     user = User.new(name: "", email: "invalid")
      #   rescue ValidationError => e
      #     puts e.message # => "name: can't be blank, email: is invalid"
      #     puts e.errors  # => [{ field: :name, message: "can't be blank" }]
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
      # Returns true when there are no validation errors present.
      # This indicates the model passed all validation rules.
      #
      # @return [Boolean] true if there are no validation errors
      #
      # @example Valid model
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.valid? # => true
      #
      # @example Invalid model (using build method to avoid exception)
      #   user = User.build(name: "", email: "invalid")
      #   user.valid? # => false
      #
      def valid?
        @errors.empty?
      end

      # Checks if the model is invalid
      #
      # Returns true when validation errors are present.
      # Opposite of the valid? method for convenience.
      #
      # @return [Boolean] true if there are validation errors
      #
      # @example Invalid model
      #   user = User.build(name: "", email: "invalid")
      #   user.invalid? # => true
      #
      # @example Valid model
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.invalid? # => false
      #
      def invalid?
        !valid?
      end

      # Returns a copy of the validated attributes
      #
      # Provides a duplicate of the internal attributes hash to prevent
      # external modification of the model's validated state.
      #
      # @return [Hash] duplicate of the attributes hash
      #
      # @example Accessing attributes
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.to_h # => { name: "John", email: "john@example.com" }
      #
      # @example Safe attribute access
      #   attrs = user.to_h
      #   attrs[:name] = "Modified"  # This won't affect the original model
      #   user.to_h[:name] # => "John" (unchanged)
      #
      def to_h
        @attributes.dup
      end

      # Returns validation errors grouped by field
      #
      # Organizes validation errors into a hash structure where field names
      # are keys and arrays of error messages are values. Useful for form
      # validation and error display.
      #
      # @return [Hash] hash with field names as keys and arrays of error messages as values
      #
      # @example Single error per field
      #   user = User.build(name: "", email: "invalid")
      #   user.errors_hash # => { name: ["can't be blank"], email: ["is invalid"] }
      #
      # @example Multiple errors per field
      #   user = User.build(name: "a" * 300, email: "")
      #   user.errors_hash # => { name: ["too long"], email: ["can't be blank", "is invalid"] }
      #
      # @example No errors
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.errors_hash # => {}
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
      # Merges new attributes with existing ones and re-validates the entire
      # model. If validation passes, updates the internal state and clears errors.
      # If validation fails, preserves original state and populates error information.
      #
      # @param new_attributes [Hash] new attributes to merge with existing ones
      # @option new_attributes [String] :name updated name value
      # @option new_attributes [String] :email updated email value
      #
      # @return [Boolean] true if validation passes, false otherwise
      #
      # @example Successful update
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.update_attributes?(email: "newemail@example.com") # => true
      #   user.to_h[:email] # => "newemail@example.com"
      #
      # @example Failed update (original state preserved)
      #   user = User.new(name: "John", email: "john@example.com")
      #   user.update_attributes?(email: "invalid") # => false
      #   user.to_h[:email] # => "john@example.com" (unchanged)
      #   user.errors_hash # => { email: ["is invalid"] }
      #
      # @example Clearing previous errors on success
      #   user.update_attributes?(email: "valid@example.com") # => true
      #   user.errors_hash # => {} (errors cleared)
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
      # Converts string keys to symbols for consistent internal representation.
      # Handles various input types gracefully, returning empty hash for invalid input.
      #
      # @param attributes [Hash, Object] attributes to normalize
      # @return [Hash] hash with symbolized keys or empty hash
      # @api private
      #
      # @example String keys conversion
      #   normalize_keys("name" => "John") # => { name: "John" }
      #
      # @example Symbol keys preserved
      #   normalize_keys(name: "John") # => { name: "John" }
      #
      # @example Invalid input handling
      #   normalize_keys("invalid") # => {}
      #   normalize_keys(nil) # => {}
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
      # Subclasses must implement this method to return their specific
      # dry-validation contract instance. This contract defines the
      # validation rules for the particular model.
      #
      # @abstract Subclasses must implement this method
      # @raise [NotImplementedError] when not implemented in subclass
      # @return [Object] dry-validation contract instance
      # @api private
      #
      # @example Implementation in subclass
      #   def validator
      #     @validator ||= Validators::UserValidator.new
      #   end
      #
      def validator
        raise NotImplementedError, "Subclasses must implement #validator method"
      end

      # Formats dry-validation errors to internal format
      #
      # Converts dry-validation error objects into a standardized internal
      # format with field names and messages. Handles nested field paths
      # by joining them with dots.
      #
      # @param dry_errors [Dry::Validation::MessageSet] errors from dry-validation
      # @return [Array<Hash>] formatted errors with :field and :message keys
      # @api private
      #
      # @example Simple field error
      #   # dry_errors with path [:name] and text "can't be blank"
      #   format_dry_errors(dry_errors) # => [{ field: :name, message: "can't be blank" }]
      #
      # @example Nested field error
      #   # dry_errors with path [:address, :street] and text "is required"
      #   format_dry_errors(dry_errors) # => [{ field: :"address.street", message: "is required" }]
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
      # Creates a human-readable error message by combining all field errors
      # into a comma-separated string. Used when raising ValidationError.
      #
      # @return [String] comma-separated error messages
      # @api private
      #
      # @example Single error
      #   # @errors = [{ field: :name, message: "can't be blank" }]
      #   format_error_messages # => "name: can't be blank"
      #
      # @example Multiple errors
      #   # @errors = [{ field: :name, message: "can't be blank" }, { field: :email, message: "is invalid" }]
      #   format_error_messages # => "name: can't be blank, email: is invalid"
      #
      def format_error_messages
        @errors.map { |error| "#{error[:field]}: #{error[:message]}" }.join(", ")
      end
    end

    # Custom exception for validation errors
    #
    # Raised when model validation fails during initialization or operations.
    # Carries both a human-readable message and structured error details
    # for programmatic access.
    #
    # @author Signetron Team
    # @since 1.0.0
    #
    # @example Catching validation errors
    #   begin
    #     User.new(name: "", email: "invalid")
    #   rescue ValidationError => e
    #     puts e.message # => "name: can't be blank, email: is invalid"
    #     e.errors.each { |error| puts "#{error[:field]}: #{error[:message]}" }
    #   end
    #
    class ValidationError < StandardError
      # @return [Array<Hash>] array of error hashes with field and message keys
      attr_reader :errors

      # Initializes validation error with message and error details
      #
      # Creates a new validation error instance with both a formatted message
      # for display and structured error data for programmatic handling.
      #
      # @param message [String] formatted error message for display
      # @param errors [Array<Hash>] array of error hashes with :field and :message keys
      # @option errors [Symbol] :field field name where error occurred
      # @option errors [String] :message human-readable error description
      #
      # @example Creating validation error
      #   errors = [
      #     { field: :name, message: "can't be blank" },
      #     { field: :email, message: "is invalid" }
      #   ]
      #   ValidationError.new("name: can't be blank, email: is invalid", errors)
      #
      def initialize(message, errors = [])
        super(message)
        @errors = errors
      end
    end
  end
end
