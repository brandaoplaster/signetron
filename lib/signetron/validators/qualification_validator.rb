# frozen_string_literal: true

require "dry-validation"
require_relative "helpers/qualification_helpers"

module Signetron
  module Validators
    # Qualification validation contract for signer-document relationships
    #
    # Validates qualification assignments between signers and documents including
    # action types, roles, UUID references, and business rule compatibility.
    # Ensures all qualification data meets format requirements and business logic.
    #
    # @example Valid qualification data
    #   validator = QualificationValidator.new
    #   result = validator.call(
    #     action: "sign",
    #     role: "signer",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    #   )
    #   result.success? # => true
    #
    # @example Valid alternative qualification
    #   result = validator.call(
    #     action: "agree",
    #     role: "witness",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    #   )
    #   result.success? # => true
    #
    # @example Invalid qualification data
    #   result = validator.call(
    #     action: "invalid",
    #     role: "unknown",
    #     document_id: "invalid-uuid",
    #     signer_id: "also-invalid"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { action: ["must be 'sign' or 'agree'"],
    #                      #      role: ["must be 'signer', 'intervening' or 'witness'"],
    #                      #      document_id: ["must be a valid UUID"],
    #                      #      signer_id: ["must be a valid UUID"] }
    #
    # @example Business rule violation
    #   result = validator.call(
    #     action: "sign",
    #     role: "witness", # incompatible with 'sign' action
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { action: ["when action is 'sign', role must be 'signer'"] }
    #
    class QualificationValidator < Dry::Validation::Contract
      include Signetron::Validators::Helpers::QualificationHelpers

      # Parameter schema definition
      #
      # All parameters are required for qualification assignments.
      # Ensures complete qualification data is provided.
      params do
        required(:action).filled(:string)
        required(:role).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      # Validates qualification action
      #
      # Ensures action is one of the allowed values: 'sign' or 'agree'.
      rule(:action) do
        validate_action(key, value)
      end

      # Validates qualification role
      #
      # Ensures role is one of the allowed values: 'signer', 'intervening', or 'witness'.
      rule(:role) do
        validate_role(key, value)
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

      # Validates action and role compatibility
      #
      # Enforces business rule: when action is 'sign', role must be 'signer'.
      # Other action-role combinations are allowed.
      rule(:action, :role) do
        validate_action_role_compatibility(key, values[:action], values[:role])
      end
    end
  end
end
