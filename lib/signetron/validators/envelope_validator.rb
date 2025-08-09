# frozen_string_literal: true

require "dry-validation"
require_relative "constants/envelope_constants"
require_relative "helpers/envelope_helpers"

module Signetron
  module Validators
    # Envelope validation contract for signature documents
    #
    # Validates envelope creation and update parameters including name,
    # status, locale, deadlines, and notification settings. Ensures all
    # envelope data meets business rules and format requirements.
    #
    # @example Valid envelope data
    #   validator = EnvelopeValidator.new
    #   result = validator.call(
    #     name: "Contract Signature",
    #     status: "draft",
    #     locale: "pt-BR",
    #     deadline_at: Date.today + 30
    #   )
    #   result.success? # => true
    #
    # @example Invalid envelope data
    #   result = validator.call(
    #     name: "A" * 300, # too long
    #     status: "invalid",
    #     locale: "xx-XX",
    #     deadline_at: Date.today - 1 # past date
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { name: ["maximum 255 characters"],
    #                      #      status: ["must be one of: draft, running, canceled, closed"],
    #                      #      locale: ["must be one of: pt-BR, en-US"],
    #                      #      deadline_at: ["must be a future date"] }
    #
    class EnvelopeValidator < Dry::Validation::Contract
      include Signetron::Validators::Helpers::EnvelopeHelpers
      EnvelopeConstants = Signetron::Validators::Constants::EnvelopeConstants

      # Parameter schema definition
      #
      # Defines required and optional parameters with their types.
      # Only name is required, all other fields are optional for flexibility.
      params do
        required(:name).filled(:string)
        optional(:status).maybe(:string)
        optional(:locale).filled(:string)
        optional(:auto_close).filled(:bool)
        optional(:block_after_refusal).filled(:bool)
        optional(:deadline_at).maybe(:date)
        optional(:remind_interval)
        optional(:default_subject).maybe(:string)
        optional(:default_message).maybe(:string)
      end

      # Validates envelope name requirements
      #
      # Ensures name does not exceed maximum character limit.
      rule(:name) do
        validate_length(key, value, EnvelopeConstants::MAX_NAME_LENGTH, EnvelopeConstants::MAX_NAME_MESSAGE)
      end

      # Validates envelope status value
      #
      # Ensures status is one of the allowed values: draft, running, canceled, closed.
      rule(:status) do
        validate_enum(key, value, EnvelopeConstants::VALID_STATUSES_SET, EnvelopeConstants::VALID_STATUSES_MESSAGE)
      end

      # Validates locale setting
      #
      # Ensures locale is supported by the system (pt-BR or en-US).
      rule(:locale) do
        validate_enum(key, value, EnvelopeConstants::VALID_LOCALES_SET, EnvelopeConstants::VALID_LOCALES_MESSAGE)
      end

      # Validates deadline date
      #
      # Ensures deadline is in the future and within maximum allowed days.
      rule(:deadline_at) do
        validate_deadline(key, value)
      end

      # Validates reminder interval setting
      #
      # Ensures remind interval is one of the allowed values or null.
      rule(:remind_interval) do
        validate_enum(key, value, EnvelopeConstants::VALID_REMIND_INTERVALS_SET, EnvelopeConstants::VALID_REMIND_INTERVALS_MESSAGE)
      end

      # Validates default subject length
      #
      # Ensures default subject does not exceed maximum character limit.
      rule(:default_subject) do
        validate_length(key, value, EnvelopeConstants::MAX_SUBJECT_LENGTH, EnvelopeConstants::MAX_SUBJECT_MESSAGE)
      end
    end
  end
end
