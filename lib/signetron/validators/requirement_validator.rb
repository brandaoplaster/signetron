# frozen_string_literal: true

require "dry-validation"
require_relative "helpers/requirement_helpers"

module Signetron
  module Validators
    # Requirement validation contract for signer evidence requirements
    #
    # Validates requirement assignments between signers and documents including
    # action types, authentication methods, and UUID references. Ensures all
    # requirement data meets format requirements for evidence collection.
    #
    # @example Valid requirement data with email auth
    #   validator = RequirementValidator.new
    #   result = validator.call(
    #     action: "provide_evidence",
    #     auth: "email",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    #   )
    #   result.success? # => true
    #
    # @example Valid requirement data with SMS auth
    #   result = validator.call(
    #     action: "provide_evidence",
    #     auth: "sms",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    #   )
    #   result.success? # => true
    #
    # @example Invalid requirement data
    #   result = validator.call(
    #     action: "invalid_action",
    #     auth: "whatsapp",
    #     document_id: "invalid-uuid",
    #     signer_id: "also-invalid"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { action: ["must be 'provide_evidence'"],
    #                      #      auth: ["must be 'email', 'sms'"],
    #                      #      document_id: ["must be a valid UUID"],
    #                      #      signer_id: ["must be a valid UUID"] }
    #
    class RequirementValidator < Dry::Validation::Contract
      include Signetron::Validators::Helpers::RequirementValidationHelpers

      # Parameter schema definition
      #
      # All parameters are required for requirement assignments.
      # Ensures complete requirement data is provided.
      params do
        required(:action).filled(:string)
        required(:auth).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      # Validates requirement action
      #
      # Ensures action is the allowed value: 'provide_evidence'.
      rule(:action) do
        validate_action(key, value)
      end

      # Validates authentication method
      #
      # Ensures auth method is one of the allowed values: 'email' or 'sms'.
      rule(:auth) do
        validate_auth(key, value)
      end

      # Validates document UUID reference
      #
      # Ensures document_id follows valid UUID format.
      rule(:document_id) do
        validate_uuid_format(key, value)
      end

      # Validates signer UUID reference
      #
      # Ensures signer_id follows valid UUID format.
      rule(:signer_id) do
        validate_uuid_format(key, value)
      end
    end
  end
end
