# frozen_string_literal: true

module Signetron
  module Validators
    module Constants
      # Signer validation constants
      #
      # Contains all validation constants for digital signature signers
      # including communication methods, validation patterns, size limits,
      # and error messages for signer data validation.
      #
      # @example Using validation constants
      #   # Check if communication method is valid
      #   method = "email"
      #   valid = SignerConstants::VALID_COMMUNICATION_METHODS_SET.include?(method)
      #
      #   # Validate email format
      #   email = "user@example.com"
      #   valid_format = email.match?(SignerConstants::EMAIL_REGEX)
      #
      module SignerConstants
        # Valid communication methods for general events
        VALID_COMMUNICATION_METHODS = %w[email sms whatsapp none].freeze

        # Valid communication methods for signature requests
        VALID_SIGNATURE_REQUEST = %w[email sms whatsapp none].freeze

        # Valid communication methods for signature reminders
        VALID_SIGNATURE_REMINDER = %w[none email].freeze

        # Valid communication methods for document signed notifications
        VALID_DOCUMENT_SIGNED = %w[email whatsapp].freeze

        # Sets for fast validation lookup
        VALID_COMMUNICATION_METHODS_SET = VALID_COMMUNICATION_METHODS.to_set.freeze
        VALID_SIGNATURE_REQUEST_SET = VALID_SIGNATURE_REQUEST.to_set.freeze
        VALID_SIGNATURE_REMINDER_SET = VALID_SIGNATURE_REMINDER.to_set.freeze
        VALID_DOCUMENT_SIGNED_SET = VALID_DOCUMENT_SIGNED.to_set.freeze

        # Maximum name length in characters
        MAX_NAME_LENGTH = 255

        # Maximum email length in characters
        MAX_EMAIL_LENGTH = 255

        # Minimum allowed age for signers
        MIN_AGE = 18

        # Maximum allowed age for signers
        MAX_AGE = 120

        # Email format validation pattern
        EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

        # Phone number format validation pattern
        PHONE_REGEX = /\A(?:\+?55[\s-]*)?(?:\(?\d{2}\)?[\s-]*)\d{4,5}[-\s]?\d{4}\z/

        # CPF documentation format validation pattern (xxx.xxx.xxx-xx)
        DOCUMENTATION_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/

        # Error messages for size limits
        MAX_NAME_MESSAGE = "maximum #{MAX_NAME_LENGTH} characters".freeze
        MAX_EMAIL_MESSAGE = "maximum #{MAX_EMAIL_LENGTH} characters".freeze

        # Error messages for name validation
        EMPTY_NAME_MESSAGE = "cannot be empty"
        NAME_FORMAT_MESSAGE = "must contain first and last name"
        NAME_NO_NUMBERS_MESSAGE = "cannot contain numbers"

        # Error messages for format validation
        EMAIL_FORMAT_MESSAGE = "invalid email format"
        PHONE_FORMAT_MESSAGE = "invalid phone format"
        DOCUMENTATION_FORMAT_MESSAGE = "CPF must be in format xxx.xxx.xxx-xx"

        # Error messages for business rules
        POSITIVE_GROUP_MESSAGE = "must be a positive integer"
        LEGAL_AGE_MESSAGE = "signer must be of legal age"
        INVALID_BIRTH_MESSAGE = "invalid birth date"

        # Error messages for field dependencies
        DOCUMENTATION_DEPENDENCY_MESSAGE = "cannot be sent when has_documentation is false"
        EMAIL_REQUIRED_MESSAGE = "is required when communicate_events contains 'email'"
        PHONE_REQUIRED_MESSAGE = "is required when communicate_events contains 'sms' or 'whatsapp'"
      end
    end
  end
end
