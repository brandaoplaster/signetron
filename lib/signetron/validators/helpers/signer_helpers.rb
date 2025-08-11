# frozen_string_literal: true

require "date"
require_relative "../constants/signer_constants"

module Signetron
  module Validators
    module Helpers
      # Signer validation helper methods
      #
      # Provides common validation helpers for signer contract validators.
      # Contains reusable methods for name validation, contact information
      # validation, age verification, and communication requirements checking.
      #
      # @example Using validation helpers in a contract
      #   class SignerValidator < Dry::Validation::Contract
      #     include Signetron::Validators::Helpers::SignerHelpers
      #
      #     rule(:name) do
      #       validate_name_length(key, value)
      #       validate_name_format(key, value)
      #       validate_name_no_numbers(key, value)
      #     end
      #
      #     rule(:email) do
      #       next unless value
      #       validate_email_format(key, value)
      #       validate_email_length(key, value)
      #     end
      #   end
      #
      module SignerHelpers
        SignerConstants = Signetron::Validators::Constants::SignerConstants

        # Validates signer name length requirements
        #
        # Ensures name is not empty and does not exceed maximum character limit.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] name value to validate
        #
        # @example Valid name
        #   validate_name_length(key, "João Silva")
        #   # No failure added
        #
        # @example Empty name
        #   validate_name_length(key, "  ")
        #   # Adds failure: "cannot be empty"
        #
        # @example Too long name
        #   validate_name_length(key, "A" * 300)
        #   # Adds failure: "maximum 255 characters"
        #
        def validate_name_length(key, value)
          key.failure(SignerConstants::EMPTY_NAME_MESSAGE) if value.strip.empty?
          key.failure(SignerConstants::MAX_NAME_MESSAGE) if value.length > SignerConstants::MAX_NAME_LENGTH
        end

        # Validates signer name format requirements
        #
        # Ensures name contains at least first and last name (minimum 2 words).
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] name value to validate
        #
        # @example Valid name format
        #   validate_name_format(key, "João Silva")
        #   # No failure added
        #
        # @example Invalid single name
        #   validate_name_format(key, "João")
        #   # Adds failure: "must contain first and last name"
        #
        def validate_name_format(key, value)
          key.failure(SignerConstants::NAME_FORMAT_MESSAGE) if value.strip.split.length < 2
        end

        # Validates that name contains no numeric characters
        #
        # Ensures name is composed only of letters and spaces.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] name value to validate
        #
        # @example Valid name without numbers
        #   validate_name_no_numbers(key, "João Silva")
        #   # No failure added
        #
        # @example Invalid name with numbers
        #   validate_name_no_numbers(key, "João Silva 123")
        #   # Adds failure: "cannot contain numbers"
        #
        def validate_name_no_numbers(key, value)
          key.failure(SignerConstants::NAME_NO_NUMBERS_MESSAGE) if value.match?(/\d/)
        end

        # Validates email address format
        #
        # Ensures email matches valid email pattern using regex validation.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] email value to validate
        #
        # @example Valid email format
        #   validate_email_format(key, "user@example.com")
        #   # No failure added
        #
        # @example Invalid email format
        #   validate_email_format(key, "invalid-email")
        #   # Adds failure: "invalid email format"
        #
        def validate_email_format(key, value)
          key.failure(SignerConstants::EMAIL_FORMAT_MESSAGE) unless value.match?(SignerConstants::EMAIL_REGEX)
        end

        # Validates email address length
        #
        # Ensures email does not exceed maximum character limit.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] email value to validate
        #
        # @example Valid email length
        #   validate_email_length(key, "user@example.com")
        #   # No failure added
        #
        # @example Too long email
        #   validate_email_length(key, "very.long.email.address" * 20 + "@example.com")
        #   # Adds failure: "maximum 255 characters"
        #
        def validate_email_length(key, value)
          key.failure(SignerConstants::MAX_EMAIL_MESSAGE) if value.length > SignerConstants::MAX_EMAIL_LENGTH
        end

        # Validates phone number format
        #
        # Ensures phone number matches valid pattern (10-15 digits with optional formatting).
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] phone value to validate
        #
        # @example Valid phone formats
        #   validate_phone_format(key, "+55 11 99999-9999")
        #   validate_phone_format(key, "(11) 99999-9999")
        #   # No failure added
        #
        # @example Invalid phone format
        #   validate_phone_format(key, "123")
        #   # Adds failure: "invalid phone format"
        #
        def validate_phone_format(key, value)
          key.failure(SignerConstants::PHONE_FORMAT_MESSAGE) unless value.match?(SignerConstants::PHONE_REGEX)
        end

        # Validates CPF documentation format
        #
        # Ensures CPF follows Brazilian format: xxx.xxx.xxx-xx.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] CPF value to validate
        #
        # @example Valid CPF format
        #   validate_documentation_format(key, "123.456.789-00")
        #   # No failure added
        #
        # @example Invalid CPF format
        #   validate_documentation_format(key, "12345678900")
        #   # Adds failure: "CPF must be in format xxx.xxx.xxx-xx"
        #
        def validate_documentation_format(key, value)
          return if value.match?(SignerConstants::DOCUMENTATION_REGEX)

          key.failure(SignerConstants::DOCUMENTATION_FORMAT_MESSAGE)
        end

        # Validates signer age based on birth date
        #
        # Ensures signer is of legal age (18+) and within reasonable age limits.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [Date] birth date to validate
        #
        # @example Valid age (adult)
        #   validate_birthday_age(key, Date.today - 25.years)
        #   # No failure added
        #
        # @example Too young (minor)
        #   validate_birthday_age(key, Date.today - 16.years)
        #   # Adds failure: "signer must be of legal age"
        #
        # @example Unrealistic age
        #   validate_birthday_age(key, Date.today - 150.years)
        #   # Adds failure: "invalid birth date"
        #
        def validate_birthday_age(key, value)
          today = Date.today
          age = today.year - value.year
          age -= 1 if today < value.next_year(age)

          if age < SignerConstants::MIN_AGE
            key.failure(SignerConstants::LEGAL_AGE_MESSAGE)
          elsif age > SignerConstants::MAX_AGE
            key.failure(SignerConstants::INVALID_BIRTH_MESSAGE)
          end
        end

        # Validates positive integer values
        #
        # Ensures value is a positive integer when present.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [Integer, nil] integer value to validate
        #
        # @example Valid positive integer
        #   validate_positive_integer(key, 5)
        #   # No failure added
        #
        # @example Invalid zero or negative
        #   validate_positive_integer(key, 0)
        #   validate_positive_integer(key, -1)
        #   # Adds failure: "must be a positive integer"
        #
        def validate_positive_integer(key, value)
          key.failure(SignerConstants::POSITIVE_GROUP_MESSAGE) if value && value < 1
        end

        # Checks if email is required based on communication events
        #
        # Determines if email field is mandatory based on communication preferences.
        #
        # @param events [Hash, nil] communication events configuration
        # @return [Boolean] true if email is required
        #
        # @example Email required
        #   needs_email?({ "signature_request" => "email" })
        #   # => true
        #
        # @example Email not required
        #   needs_email?({ "signature_request" => "sms" })
        #   # => false
        #
        def needs_email?(events)
          events&.values&.include?("email")
        end

        # Checks if phone is required based on communication events
        #
        # Determines if phone field is mandatory based on communication preferences.
        #
        # @param events [Hash, nil] communication events configuration
        # @return [Boolean] true if phone is required
        #
        # @example Phone required for SMS
        #   needs_phone?({ "signature_request" => "sms" })
        #   # => true
        #
        # @example Phone required for WhatsApp
        #   needs_phone?({ "signature_request" => "whatsapp" })
        #   # => true
        #
        # @example Phone not required
        #   needs_phone?({ "signature_request" => "email" })
        #   # => false
        #
        def needs_phone?(events)
          events&.values&.any? { |v| %w[sms whatsapp].include?(v) }
        end
      end
    end
  end
end
