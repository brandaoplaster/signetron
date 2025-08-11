# frozen_string_literal: true

module Signetron
  module Validators
    module Constants
      # Envelope validation constants
      #
      # Contains all validation constants for digital signature envelopes
      # including valid values, limits and error messages for document
      # validation, localization settings, status definitions and size limitations.
      #
      # @example Using validation constants
      #   # Check if locale is valid
      #   locale = "pt-BR"
      #   valid = EnvelopeConstants::VALID_LOCALES_SET.include?(locale)
      #
      #   # Get error message for invalid status
      #   error_msg = EnvelopeConstants::VALID_STATUSES_MESSAGE
      #
      module EnvelopeConstants
        # Valid locales supported by the system
        VALID_LOCALES = %w[pt-BR en-US].freeze

        # Valid status values for signature envelopes
        VALID_STATUSES = %w[draft running canceled closed].freeze

        # Valid reminder intervals in days (nil = no reminder)
        VALID_REMIND_INTERVALS = [nil, 1, 2, 3, 7, 14].freeze

        # Sets for fast validation lookup
        VALID_LOCALES_SET = VALID_LOCALES.to_set.freeze
        VALID_STATUSES_SET = VALID_STATUSES.to_set.freeze
        VALID_REMIND_INTERVALS_SET = VALID_REMIND_INTERVALS.to_set.freeze

        # Error messages for validation
        VALID_LOCALES_MESSAGE = "must be one of: #{VALID_LOCALES.join(', ')}".freeze
        VALID_STATUSES_MESSAGE = "must be one of: #{VALID_STATUSES.join(', ')}".freeze
        VALID_REMIND_INTERVALS_MESSAGE = "must be one of: null, 1, 2, 3, 7, 14"

        # Maximum name length in characters
        MAX_NAME_LENGTH = 255

        # Maximum subject length in characters
        MAX_SUBJECT_LENGTH = 100

        # Maximum deadline days from current date
        MAX_DEADLINE_DAYS = 90

        # Error messages for size limits
        MAX_NAME_MESSAGE = "maximum #{MAX_NAME_LENGTH} characters".freeze
        MAX_SUBJECT_MESSAGE = "maximum #{MAX_SUBJECT_LENGTH} characters".freeze
        MAX_DEADLINE_MESSAGE = "maximum #{MAX_DEADLINE_DAYS} days from now".freeze
        FUTURE_DATE_MESSAGE = "must be a future date"
      end
    end
  end
end
