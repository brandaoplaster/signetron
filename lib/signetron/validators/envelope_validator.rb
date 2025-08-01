# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Envelope validation contract using dry-validation
    #
    # Validates envelope attributes including name, locale, timing settings,
    # and external identifiers. Ensures data integrity and business rules
    # compliance for envelope creation and updates.
    #
    # @example Valid envelope data
    #   validator = EnvelopeValidator.new
    #   result = validator.call(
    #     name: "Contract Agreement",
    #     locale: "pt-BR",
    #     sequence_enabled: true,
    #     deadline_at: 1.week.from_now
    #   )
    #   result.success? # => true
    #
    # @example Invalid envelope data
    #   result = validator.call(name: "", locale: "invalid", remind_interval: 50)
    #   result.success? # => false
    #   result.errors.to_h # => { name: ["must have at least 1 character"],
    #                      #      locale: ["must be one of: pt-BR, en-US, es-ES"],
    #                      #      remind_interval: ["must be between 1 and 30 days"] }
    #
    class EnvelopeValidator < Dry::Validation::Contract
      # Valid locale codes supported by the system
      VALID_LOCALES = %w[pt-BR en-US es-ES].freeze

      # Minimum reminder interval in days
      MIN_REMIND_INTERVAL = 1

      # Maximum reminder interval in days
      MAX_REMIND_INTERVAL = 30

      # Maximum length for envelope name
      MAX_NAME_LENGTH = 255

      # Maximum length for external ID
      MAX_EXTERNAL_ID_LENGTH = 255

      # Parameter schema definition
      #
      # Defines the expected structure and types for envelope attributes.
      # All parameters except name are optional and can be nil.
      params do
        required(:name).filled(:string)
        optional(:locale).maybe(:string)
        optional(:sequence_enabled).maybe(:bool)
        optional(:auto_close).maybe(:bool)
        optional(:block_after_refusal).maybe(:bool)
        optional(:deadline_at).maybe(:date_time)
        optional(:remind_interval).maybe(:integer)
        optional(:external_id).maybe(:string)
      end

      # Validates envelope name requirements
      #
      # @example Valid names
      #   "Contract Agreement" # => valid
      #   "A" # => valid (minimum 1 character)
      #
      # @example Invalid names
      #   "" # => "must have at least 1 character"
      #   "x" * 256 # => "maximum 255 characters"
      #
      rule(:name) do
        if key? && value
          key.failure("must have at least 1 character") if value.empty?
          key.failure("maximum #{MAX_NAME_LENGTH} characters") if value.length > MAX_NAME_LENGTH
        end
      end

      # Validates locale format and supported languages
      #
      # @example Valid locales
      #   "pt-BR" # => valid
      #   "en-US" # => valid
      #   "es-ES" # => valid
      #
      # @example Invalid locales
      #   "pt" # => "must be one of: pt-BR, en-US, es-ES"
      #   "fr-FR" # => "must be one of: pt-BR, en-US, es-ES"
      #
      rule(:locale) do
        key.failure("must be one of: #{VALID_LOCALES.join(', ')}") if key? && value && !VALID_LOCALES.include?(value)
      end

      # Validates deadline is in the future
      #
      # @example Valid deadlines
      #   1.day.from_now # => valid
      #   DateTime.parse("2025-12-31") # => valid
      #
      # @example Invalid deadlines
      #   1.day.ago # => "must be a future date"
      #   DateTime.now # => "must be a future date"
      #
      rule(:deadline_at) do
        key.failure("must be a future date") if key? && value && (value <= DateTime.now)
      end

      # Validates reminder interval is within acceptable range
      #
      # @example Valid intervals
      #   1 # => valid (minimum)
      #   15 # => valid
      #   30 # => valid (maximum)
      #
      # @example Invalid intervals
      #   0 # => "must be between 1 and 30 days"
      #   31 # => "must be between 1 and 30 days"
      #   -5 # => "must be between 1 and 30 days"
      #
      rule(:remind_interval) do
        if key? && value && !value.between?(MIN_REMIND_INTERVAL, MAX_REMIND_INTERVAL)
          key.failure("must be between #{MIN_REMIND_INTERVAL} and #{MAX_REMIND_INTERVAL} days")
        end
      end

      # Validates external ID length
      #
      # @example Valid external IDs
      #   "ext_12345" # => valid
      #   "a" * 255 # => valid (maximum length)
      #
      # @example Invalid external IDs
      #   "a" * 256 # => "maximum 255 characters"
      #
      rule(:external_id) do
        if key? && value && (value.length > MAX_EXTERNAL_ID_LENGTH)
          key.failure("maximum #{MAX_EXTERNAL_ID_LENGTH} characters")
        end
      end
    end
  end
end
