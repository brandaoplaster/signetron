# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Signer validation contract for participant data
    #
    # Validates signer information including personal details, contact information,
    # authentication methods, and security settings. Ensures all signers meet
    # legal and business requirements for document signing.
    #
    # @example Valid signer data
    #   validator = SignerValidator.new
    #   result = validator.call(
    #     email: "john@example.com",
    #     name: "John Doe",
    #     phone_number: "+1234567890",
    #     auths: ["email", "sms"],
    #     birthday: Date.new(1990, 5, 15)
    #   )
    #   result.success? # => true
    #
    # @example Invalid signer data
    #   result = validator.call(
    #     email: "invalid-email",
    #     name: "John",
    #     auths: ["invalid_method"]
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { email: ["invalid email format"],
    #                      #      name: ["must contain first and last name"],
    #                      #      auths: ["invalid authentication methods: invalid_method"] }
    #
    class SignerValidator < Dry::Validation::Contract
      # Valid authentication methods supported by the system
      VALID_AUTHS = %w[email sms selfie official_document facial_biometrics].freeze

      # Maximum name length in characters
      MAX_NAME_LENGTH = 255

      # Maximum email length in characters
      MAX_EMAIL_LENGTH = 255

      # Email format validation regex
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

      # Phone number format validation regex (10-15 digits with optional formatting)
      PHONE_REGEX = /\A[\d\s\-\(\)]{10,15}\z/

      # Brazilian CPF documentation format regex
      DOCUMENTATION_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/

      # Parameter schema definition
      #
      # Requires email and name as mandatory fields. All other signer
      # attributes are optional and can be nil.
      params do
        required(:email).filled(:string)
        required(:name).filled(:string)
        optional(:phone_number).maybe(:string)
        optional(:documentation).maybe(:string)
        optional(:birthday).maybe(:date)
        optional(:auths).maybe(:array)
        optional(:has_documentation).maybe(:bool)
        optional(:selfie_enabled).maybe(:bool)
        optional(:handwritten_enabled).maybe(:bool)
        optional(:official_document_enabled).maybe(:bool)
        optional(:liveness_enabled).maybe(:bool)
        optional(:facial_biometrics_enabled).maybe(:bool)
      end

      # Validates email format and length requirements
      #
      # @example Valid emails
      #   "user@example.com" # => valid
      #   "john.doe+test@company.org" # => valid
      #
      # @example Invalid emails
      #   "invalid-email" # => "invalid email format"
      #   "user@" # => "invalid email format"
      #   "a" * 250 + "@example.com" # => "maximum 255 characters"
      #
      rule(:email) do
        validate_email_format(value)
        validate_email_length(value)
      end

      # Validates name format and length requirements
      #
      # @example Valid names
      #   "John Doe" # => valid
      #   "Maria Silva Santos" # => valid
      #
      # @example Invalid names
      #   "" # => "cannot be empty"
      #   "John" # => "must contain first and last name"
      #   "a" * 300 # => "maximum 255 characters"
      #
      rule(:name) do
        validate_name_length(value)
        validate_name_format(value)
      end

      # Validates phone number format when provided
      #
      # @example Valid phone numbers
      #   "+1234567890" # => valid
      #   "(11) 99999-9999" # => valid
      #   "11 99999-9999" # => valid
      #
      # @example Invalid phone numbers
      #   "123" # => "invalid phone format"
      #   "abcd1234567890" # => "invalid phone format"
      #
      rule(:phone_number) do
        validate_phone_format(value) if value
      end

      # Validates Brazilian CPF documentation format when provided
      #
      # @example Valid CPF
      #   "123.456.789-00" # => valid
      #
      # @example Invalid CPF
      #   "12345678900" # => "CPF must be in format xxx.xxx.xxx-xx"
      #   "123.456.789" # => "CPF must be in format xxx.xxx.xxx-xx"
      #
      rule(:documentation) do
        validate_documentation_format(value) if value
      end

      # Validates birthday for age requirements when provided
      #
      # @example Valid birthdays
      #   Date.new(1990, 5, 15) # => valid (adult)
      #   Date.new(1950, 1, 1) # => valid
      #
      # @example Invalid birthdays
      #   Date.new(2010, 1, 1) # => "signer must be of legal age"
      #   Date.new(1900, 1, 1) # => "invalid birth date"
      #
      rule(:birthday) do
        validate_birthday_age(value) if value
      end

      # Validates authentication methods when provided
      #
      # @example Valid auth methods
      #   ["email", "sms"] # => valid
      #   ["selfie", "official_document"] # => valid
      #
      # @example Invalid auth methods
      #   ["invalid_method"] # => "invalid authentication methods: invalid_method"
      #   [] # => "must contain at least one authentication method"
      #
      rule(:auths) do
        validate_auths_values(value) if value
      end

      private

      # Validates email format using regex
      #
      # @param value [String] email to validate
      # @return [void]
      #
      def validate_email_format(value)
        return if value.match?(EMAIL_REGEX)

        key.failure("invalid email format")
      end

      # Validates email length constraint
      #
      # @param value [String] email to validate
      # @return [void]
      #
      def validate_email_length(value)
        return unless value.length > MAX_EMAIL_LENGTH

        key.failure("maximum #{MAX_EMAIL_LENGTH} characters")
      end

      # Validates name length and emptiness
      #
      # @param value [String] name to validate
      # @return [void]
      #
      def validate_name_length(value)
        key.failure("cannot be empty") if value.strip.empty?
        key.failure("maximum #{MAX_NAME_LENGTH} characters") if value.length > MAX_NAME_LENGTH
      end

      # Validates name contains both first and last name
      #
      # @param value [String] name to validate
      # @return [void]
      #
      def validate_name_format(value)
        return unless value.strip.split.length < 2

        key.failure("must contain first and last name")
      end

      # Validates phone number format using regex
      #
      # @param value [String] phone number to validate
      # @return [void]
      #
      def validate_phone_format(value)
        return if value.match?(PHONE_REGEX)

        key.failure("invalid phone format")
      end

      # Validates Brazilian CPF documentation format
      #
      # @param value [String] CPF to validate
      # @return [void]
      #
      def validate_documentation_format(value)
        return if value.match?(DOCUMENTATION_REGEX)

        key.failure("CPF must be in format xxx.xxx.xxx-xx")
      end

      # Validates age requirements based on birthday
      #
      # @param value [Date] birthday to validate
      # @return [void]
      #
      def validate_birthday_age(value)
        today = Date.today
        age = today.year - value.year
        age -= 1 if today < value.next_year(age)

        if age < 18
          key.failure("signer must be of legal age")
        elsif age > 120
          key.failure("invalid birth date")
        end
      end

      # Validates authentication methods array
      #
      # @param value [Array] authentication methods to validate
      # @return [void]
      #
      def validate_auths_values(value)
        return unless value.is_a?(Array)

        invalid_auths = value - VALID_AUTHS
        key.failure("invalid authentication methods: #{invalid_auths.join(', ')}") unless invalid_auths.empty?

        return unless value.empty?

        key.failure("must contain at least one authentication method")
      end
    end
  end
end
