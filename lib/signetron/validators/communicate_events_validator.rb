# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # CommunicateEvents validation contract
    #
    # Validates communication events configuration according to API requirements.
    # Each event type has specific allowed values that must be enforced.
    #
    #   validator = CommunicateEventsValidator.new
    #   result = validator.call(signature_request: "email")
    #   result.success? # => true
    #
    #   result = validator.call(signature_request: "invalid")
    #   result.success? # => false
    #   result.errors # => { signature_request: ["must be one of: email, sms, whatsapp, none"] }
    class CommunicateEventsValidator < Dry::Validation::Contract
      # Parameter schema definition
      params do
        optional(:signature_request).maybe(:string)
        optional(:signature_reminder).maybe(:string)
        optional(:document_signed).maybe(:string)
      end

      # Validates signature_request values
      #
      # Ensures signature_request is one of the allowed values for
      # communicating signature requests to signers.
      rule(:signature_request) do
        if value && !%w[email sms whatsapp none].include?(value)
          key.failure("must be one of: email, sms, whatsapp, none")
        end
      end

      # Validates signature_reminder values
      #
      # Ensures signature_reminder is one of the allowed values for
      # sending signature reminders to signers.
      rule(:signature_reminder) do
        key.failure("must be one of: none, email") if value && !%w[none email].include?(value)
      end

      # Validates document_signed values
      #
      # Ensures document_signed is one of the allowed values for
      # notifying signers when document is fully signed.
      rule(:document_signed) do
        key.failure("must be one of: email, whatsapp") if value && !%w[email whatsapp].include?(value)
      end
    end
  end
end
