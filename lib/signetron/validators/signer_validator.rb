# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    ##
    # Signer validation contract for participant data
    #
    # Validates signer information based on API requirements including
    # personal details, contact information, and communication settings.
    # Ensures all signers meet business requirements for document signing.
    #
    # Example valid signer data:
    #   validator = SignerValidator.new
    #   result = validator.call(
    #     name: "John Doe",
    #     email: "john@example.com",
    #     phone_number: "+1234567890",
    #     has_documentation: true,
    #     documentation: "123.456.789-00",
    #     birthday: Date.new(1990, 5, 15),
    #     refusable: true,
    #     group: 1,
    #     location_required_enabled: false,
    #     communicate_events: {
    #       signature_request: "email",
    #       signature_reminder: "email",
    #       document_signed: "email"
    #     }
    #   )
    #   result.success? # => true
    #
    class SignerValidator < Dry::Validation::Contract
      # Valid communication methods for events
      VALID_COMMUNICATION_METHODS = %w[email sms whatsapp none].freeze

      # Valid signature request methods
      VALID_SIGNATURE_REQUEST = %w[email sms whatsapp none].freeze

      # Valid signature reminder methods
      VALID_SIGNATURE_REMINDER = %w[none email].freeze

      # Valid document signed notification methods
      VALID_DOCUMENT_SIGNED = %w[email whatsapp].freeze

      # Maximum name length in characters
      MAX_NAME_LENGTH = 255

      # Maximum email length in characters
      MAX_EMAIL_LENGTH = 255

      # Email format validation regex
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

      # Phone number format validation regex (10-15 digits with optional formatting)
      PHONE_REGEX = /\A[\d\s\-\(\)\+]{10,15}\z/

      # Brazilian CPF documentation format regex
      DOCUMENTATION_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/

      # Parameter schema definition based on API documentation
      params do
        required(:name).filled(:string)
        optional(:email).maybe(:string)
        optional(:phone_number).maybe(:string)
        optional(:has_documentation).maybe(:bool)
        optional(:documentation).maybe(:string)
        optional(:birthday).maybe(:date)
        optional(:refusable).maybe(:bool)
        optional(:group).maybe(:integer)
        optional(:location_required_enabled).maybe(:bool)
        optional(:communicate_events).maybe(:hash)
      end

      # Validates name format and length requirements
      #
      # Must contain at least first name and last name.
      # Cannot contain numbers.
      rule(:name) do
        validate_name_length(value)
        validate_name_format(value)
        validate_name_no_numbers(value)
      end

      # Validates email format and length when provided
      #
      # Required only if communicate_events contains "email" values.
      rule(:email) do
        if value
          validate_email_format(value)
          validate_email_length(value)
        end
      end

      # Validates phone number format when provided
      #
      # Required only if communicate_events contains "sms" or "whatsapp" values.
      rule(:phone_number) do
        validate_phone_format(value) if value
      end

      # Validates documentation format when provided
      #
      # Can only be sent if has_documentation is true.
      rule(:documentation) do
        validate_documentation_format(value) if value
      end

      # Validates birthday for age requirements when provided
      #
      # Can only be sent if has_documentation is true.
      rule(:birthday) do
        validate_birthday_age(value) if value
      end

      # Validates group number is positive when provided
      rule(:group) do
        key.failure("must be a positive integer") if value && value < 1
      end

      # Validates communicate_events when provided
      #
      # Delegates validation to dedicated CommunicateEventsValidator
      rule(:communicate_events) do
        if value
          events_result = Validators::CommunicateEventsValidator.new.call(value)
          unless events_result.success?
            events_result.errors.each do |error|
              key.failure("communicate_events.#{error.path.join('.')}: #{error.text}")
            end
          end
        end
      end

      # Validates has_documentation dependencies
      #
      # If has_documentation is false, documentation and birthday cannot be sent.
      rule(:has_documentation, :documentation, :birthday) do
        if values[:has_documentation] == false
          key(:documentation).failure("cannot be sent when has_documentation is false") if values[:documentation]
          key(:birthday).failure("cannot be sent when has_documentation is false") if values[:birthday]
        end
      end

      # Validates email requirement based on communicate_events
      rule(:email, :communicate_events) do
        if values[:communicate_events]
          events_validator = Validators::CommunicateEventsValidator.new
          events_result = events_validator.call(values[:communicate_events])

          if events_result.success?
            events = values[:communicate_events]
            needs_email = events.values.include?("email")

            if needs_email && !values[:email]
              key(:email).failure("is required when communicate_events contains 'email'")
            end
          end
        end
      end

      # Validates phone requirement based on communicate_events
      rule(:phone_number, :communicate_events) do
        if values[:communicate_events]
          events_validator = Validators::CommunicateEventsValidator.new
          events_result = events_validator.call(values[:communicate_events])

          if events_result.success?
            events = values[:communicate_events]
            needs_phone = events.values.any? { |v| %w[sms whatsapp].include?(v) }

            if needs_phone && !values[:phone_number]
              key(:phone_number).failure("is required when communicate_events contains 'sms' or 'whatsapp'")
            end
          end
        end
      end

      private

      ##
      # Validates name length and emptiness
      def validate_name_length(value)
        key.failure("cannot be empty") if value.strip.empty?
        key.failure("maximum #{MAX_NAME_LENGTH} characters") if value.length > MAX_NAME_LENGTH
      end

      ##
      # Validates name contains both first and last name
      def validate_name_format(value)
        return unless value.strip.split.length < 2

        key.failure("must contain first and last name")
      end

      ##
      # Validates name does not contain numbers
      def validate_name_no_numbers(value)
        return unless value.match?(/\d/)

        key.failure("cannot contain numbers")
      end

      ##
      # Validates email format using regex
      def validate_email_format(value)
        return if value.match?(EMAIL_REGEX)

        key.failure("invalid email format")
      end

      ##
      # Validates email length constraint
      def validate_email_length(value)
        return unless value.length > MAX_EMAIL_LENGTH

        key.failure("maximum #{MAX_EMAIL_LENGTH} characters")
      end

      ##
      # Validates phone number format using regex
      def validate_phone_format(value)
        return if value.match?(PHONE_REGEX)

        key.failure("invalid phone format")
      end

      ##
      # Validates Brazilian CPF documentation format
      def validate_documentation_format(value)
        return if value.match?(DOCUMENTATION_REGEX)

        key.failure("CPF must be in format xxx.xxx.xxx-xx")
      end

      ##
      # Validates age requirements based on birthday
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
    end
  end
end
