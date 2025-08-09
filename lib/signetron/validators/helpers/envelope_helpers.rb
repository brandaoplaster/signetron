# frozen_string_literal: true

require "date"
require_relative "../constants/envelope_constants"

module Signetron
  module Validators
    module Helpers
      # Envelope validation helper methods
      #
      # Provides common validation helpers for envelope contract validators.
      # Contains reusable methods for length validation, enumeration validation,
      # and date validation with predefined error messages and limits.
      #
      # @example Using validation helpers in a contract
      #   class EnvelopeValidator < Dry::Validation::Contract
      #     include Signetron::Validators::Helpers::EnvelopeHelpers
      #
      #     rule(:name) do
      #       validate_length(key, value, MAX_NAME_LENGTH, MAX_NAME_MESSAGE)
      #     end
      #
      #     rule(:status) do
      #       validate_enum(key, value, VALID_STATUSES_SET, VALID_STATUSES_MESSAGE)
      #     end
      #   end
      #
      module EnvelopeHelpers
        EnvelopeConstants = Signetron::Validators::Constants::EnvelopeConstants

        # Validates string length against maximum limit
        #
        # Adds validation failure if value exceeds the specified maximum length.
        # Safely handles nil values and uses safe navigation operators.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String, nil] string value to validate
        # @param max_length [Integer] maximum allowed length
        # @param message [String] error message to display on failure
        #
        # @example Validate name length
        #   validate_length(key, "Very long name", 10, "maximum 10 characters")
        #   # Adds failure: "maximum 10 characters"
        #
        # @example With nil value
        #   validate_length(key, nil, 10, "maximum 10 characters")
        #   # No failure added (nil is safe)
        #
        def validate_length(key, value, max_length, message)
          key.failure(message) if value&.length&.> max_length
        end

        # Validates value against allowed enumeration set
        #
        # Adds validation failure if value is not included in the valid set.
        # Skips validation for nil values to allow optional fields.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [Object, nil] value to validate against enumeration
        # @param valid_set [Set] set of valid values
        # @param message [String] error message to display on failure
        #
        # @example Validate status enum
        #   validate_enum(key, "invalid", VALID_STATUSES_SET, "must be draft, running, canceled, or closed")
        #   # Adds failure: "must be draft, running, canceled, or closed"
        #
        # @example With valid value
        #   validate_enum(key, "draft", VALID_STATUSES_SET, "invalid status")
        #   # No failure added
        #
        def validate_enum(key, value, valid_set, message)
          key.failure(message) if value && !valid_set.include?(value)
        end

        # Validates deadline date requirements
        #
        # Ensures deadline is a future date and within allowed maximum days limit.
        # Uses constants from EnvelopeConstants for validation rules.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [Date, nil] deadline date to validate
        #
        # @example Valid future deadline
        #   validate_deadline(key, Date.today + 30)
        #   # No failure added
        #
        # @example Past date deadline
        #   validate_deadline(key, Date.today - 1)
        #   # Adds failure: "must be a future date"
        #
        # @example Too far future deadline
        #   validate_deadline(key, Date.today + 100)
        #   # Adds failure: "maximum 90 days from now"
        #
        def validate_deadline(key, value)
          return unless value

          if value <= Date.today
            key.failure(EnvelopeConstants::FUTURE_DATE_MESSAGE)
          elsif value > Date.today + EnvelopeConstants::MAX_DEADLINE_DAYS
            key.failure(EnvelopeConstants::MAX_DEADLINE_MESSAGE)
          end
        end
      end
    end
  end
end
