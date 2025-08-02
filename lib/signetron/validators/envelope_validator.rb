# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Envelope validation contract using dry-validation
    #
    # Validates envelope attributes according to Signetron API business rules
    # including name, locale, status, timing settings, and external identifiers.
    # Ensures data integrity and compliance before sending to API.
    #
    # @author Signetron Team
    # @since 1.0.0
    #
    # @example Valid envelope data
    #   validator = EnvelopeValidator.new
    #   result = validator.call(
    #     name: "Contract Agreement",
    #     locale: "pt-BR",
    #     auto_close: true,
    #     deadline_at: 15.days.from_now
    #   )
    #   result.success? # => true
    #
    # @example Invalid envelope data
    #   result = validator.call(name: "", locale: "invalid", remind_interval: 50)
    #   result.success? # => false
    #   result.errors.to_h # => { name: ["can't be blank"],
    #                      #      locale: ["must be one of: pt-BR, en-US"],
    #                      #      remind_interval: ["must be one of: 1, 2, 3, 7, 14"] }
    #
    class EnvelopeValidator < Dry::Validation::Contract
      # Valid locale codes supported by the system
      VALID_LOCALES = %w[pt-BR en-US].freeze

      # Valid status values for envelope lifecycle
      VALID_STATUSES = %w[draft running canceled closed].freeze

      # Valid reminder interval values in days
      VALID_REMIND_INTERVALS = [1, 2, 3, 7, 14].freeze

      # Maximum length for envelope name
      MAX_NAME_LENGTH = 255

      # Maximum length for external ID
      MAX_EXTERNAL_ID_LENGTH = 255

      # Maximum length for default subject
      MAX_SUBJECT_LENGTH = 100

      # Maximum deadline in days from now
      MAX_DEADLINE_DAYS = 90

      # Parameter schema definition
      #
      # Defines the expected structure and types for envelope attributes.
      # Only name is required for creation, other fields are optional.
      params do
        required(:name).filled(:string)
        optional(:status).maybe(:string)
        optional(:locale).maybe(:string)
        optional(:auto_close).maybe(:bool)
        optional(:block_after_refusal).maybe(:bool)
        optional(:deadline_at).maybe(:date_time)
        optional(:remind_interval).maybe(:integer)
        optional(:external_id).maybe(:string)
        optional(:default_subject).maybe(:string)
        optional(:default_message).maybe(:string)
      end

      # Validates envelope name requirements
      #
      # Name is required and must be present with at least 1 character.
      # Maximum length is 255 characters.
      #
      # @example Valid names
      #   "Contract Agreement" # => valid
      #   "A" # => valid (minimum 1 character)
      #
      # @example Invalid names
      #   "" # => "can't be blank"
      #   "x" * 256 # => "maximum 255 characters"
      #
      rule(:name) do
        if key? && value
          key.failure("can't be blank") if value.empty?
          key.failure("maximum #{MAX_NAME_LENGTH} characters") if value.length > MAX_NAME_LENGTH
        end
      end

      # Validates status values for envelope lifecycle
      #
      # Status controls envelope activation and is used during updates.
      # Only specific lifecycle values are allowed.
      #
      # @example Valid statuses
      #   "draft" # => valid
      #   "running" # => valid
      #   "canceled" # => valid
      #   "closed" # => valid
      #
      # @example Invalid statuses
      #   "pending" # => "must be one of: draft, running, canceled, closed"
      #   "active" # => "must be one of: draft, running, canceled, closed"
      #
      rule(:status) do
        key.failure("must be one of: #{VALID_STATUSES.join(', ')}") if key? && value && !VALID_STATUSES.include?(value)
      end

      # Validates locale format and supported languages
      #
      # Determines document language for emails, signature pages, and logs.
      # Only pt-BR and en-US are currently supported.
      #
      # @example Valid locales
      #   "pt-BR" # => valid
      #   "en-US" # => valid
      #
      # @example Invalid locales
      #   "pt" # => "must be one of: pt-BR, en-US"
      #   "fr-FR" # => "must be one of: pt-BR, en-US"
      #
      rule(:locale) do
        key.failure("must be one of: #{VALID_LOCALES.join(', ')}") if key? && value && !VALID_LOCALES.include?(value)
      end

      # Validates deadline is in the future and within limits
      #
      # Deadline must be a future date and cannot exceed 90 days from now.
      # Document will be automatically finalized when deadline is reached.
      #
      # @example Valid deadlines
      #   1.day.from_now # => valid
      #   89.days.from_now # => valid
      #
      # @example Invalid deadlines
      #   1.day.ago # => "must be a future date"
      #   91.days.from_now # => "maximum 90 days from now"
      #
      rule(:deadline_at) do
        if key? && value
          now = DateTime.now
          max_deadline = now + MAX_DEADLINE_DAYS.days

          key.failure("must be a future date") if value <= now
          key.failure("maximum #{MAX_DEADLINE_DAYS} days from now") if value > max_deadline
        end
      end

      # Validates reminder interval values
      #
      # Only specific interval values are allowed for automatic reminders.
      # Up to three reminders will be sent at the specified interval.
      #
      # @example Valid intervals
      #   1 # => valid (daily)
      #   7 # => valid (weekly)
      #   14 # => valid (bi-weekly)
      #
      # @example Invalid intervals
      #   5 # => "must be one of: 1, 2, 3, 7, 14"
      #   30 # => "must be one of: 1, 2, 3, 7, 14"
      #
      rule(:remind_interval) do
        if key? && value && !VALID_REMIND_INTERVALS.include?(value)
          key.failure("must be one of: #{VALID_REMIND_INTERVALS.join(', ')}")
        end
      end

      # Validates external ID length
      #
      # External identifier for integration with external systems.
      # Must not exceed maximum length limit.
      #
      # @example Valid external IDs
      #   "ext_12345" # => valid
      #   "a" * 255 # => valid (maximum length)
      #
      # @example Invalid external IDs
      #   "a" * 256 # => "maximum 255 characters"
      #
      rule(:external_id) do
        if key? && value && value.length > MAX_EXTERNAL_ID_LENGTH
          key.failure("maximum #{MAX_EXTERNAL_ID_LENGTH} characters")
        end
      end

      # Validates default subject length
      #
      # Default subject for signature request emails.
      # Must not exceed 100 characters as per API limits.
      #
      # @example Valid subjects
      #   "Please sign this document" # => valid
      #   "a" * 100 # => valid (maximum length)
      #
      # @example Invalid subjects
      #   "a" * 101 # => "maximum 100 characters"
      #
      rule(:default_subject) do
        key.failure("maximum #{MAX_SUBJECT_LENGTH} characters") if key? && value && value.length > MAX_SUBJECT_LENGTH
      end
    end
  end
end
