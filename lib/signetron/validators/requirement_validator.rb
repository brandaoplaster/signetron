# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Requirement validation contract for signing requirements
    #
    # Validates requirement data that links signers to documents with specific
    # actions and authentication methods. Ensures proper UUID format for
    # entity references and validates allowed actions and auth methods.
    #
    # @example Valid requirement data
    #   validator = RequirementValidator.new
    #   result = validator.call(
    #     action: "provide_evidence",
    #     auth: "email",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "123e4567-e89b-12d3-a456-426614174000"
    #   )
    #   result.success? # => true
    #
    # @example Invalid requirement data
    #   result = validator.call(
    #     action: "invalid_action",
    #     auth: "invalid_auth",
    #     document_id: "not-a-uuid",
    #     signer_id: "also-not-uuid"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { action: ["must be 'provide_evidence'"],
    #                      #      auth: ["must be 'email', 'sms', 'selfie' or 'pix'"],
    #                      #      document_id: ["must be a valid UUID"],
    #                      #      signer_id: ["must be a valid UUID"] }
    #
    class RequirementValidator < Dry::Validation::Contract
      # Valid requirement actions supported by the system
      VALID_ACTIONS = %w[provide_evidence].freeze

      # Valid authentication methods for requirements
      VALID_AUTHS = %w[email sms].freeze

      # UUID format validation regex (RFC 4122 compliant)
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

      # Parameter schema definition
      #
      # All parameters are required and must be non-empty strings.
      # References to documents and signers must be valid UUIDs.
      params do
        required(:action).filled(:string)
        required(:auth).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      # Validates requirement action is supported
      #
      # @example Valid actions
      #   "provide_evidence" # => valid
      #
      # @example Invalid actions
      #   "sign" # => "must be 'provide_evidence'"
      #   "approve" # => "must be 'provide_evidence'"
      #   "" # => "must be 'provide_evidence'"
      #
      rule(:action) do
        key.failure("must be 'provide_evidence'") unless VALID_ACTIONS.include?(value)
      end

      # Validates authentication method is supported
      #
      # Note: Error message mentions 'selfie' and 'pix' but they are not
      # included in VALID_AUTHS constant. This may be intentional for
      # future compatibility or an oversight.
      #
      # @example Valid auth methods
      #   "email" # => valid
      #   "sms" # => valid
      #
      # @example Invalid auth methods
      #   "selfie" # => "must be 'email', 'sms', 'selfie' or 'pix'"
      #   "biometric" # => "must be 'email', 'sms', 'selfie' or 'pix'"
      #
      rule(:auth) do
        key.failure("must be 'email', 'sms'") unless VALID_AUTHS.include?(value)
      end

      # Validates document ID is a properly formatted UUID
      #
      # @example Valid document IDs
      #   "550e8400-e29b-41d4-a716-446655440000" # => valid
      #   "123e4567-e89b-12d3-a456-426614174000" # => valid
      #
      # @example Invalid document IDs
      #   "not-a-uuid" # => "must be a valid UUID"
      #   "12345" # => "must be a valid UUID"
      #   "550e8400-e29b-41d4-a716" # => "must be a valid UUID"
      #
      rule(:document_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      # Validates signer ID is a properly formatted UUID
      #
      # @example Valid signer IDs
      #   "123e4567-e89b-12d3-a456-426614174000" # => valid
      #   "550e8400-e29b-41d4-a716-446655440000" # => valid
      #
      # @example Invalid signer IDs
      #   "invalid-id" # => "must be a valid UUID"
      #   "12345678-1234-1234-1234" # => "must be a valid UUID"
      #   "" # => "must be a valid UUID"
      #
      rule(:signer_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      private

      # Checks if value matches UUID format
      #
      # Uses RFC 4122 compliant regex to validate UUID format.
      # Case-insensitive matching allows both uppercase and lowercase.
      #
      # @param value [String] string to validate as UUID
      # @return [Boolean] true if value matches UUID format
      #
      # @example
      #   uuid_format?("550e8400-e29b-41d4-a716-446655440000") # => true
      #   uuid_format?("ABCD1234-5678-90EF-GHIJ-KLMNOPQRSTUV") # => false
      #   uuid_format?("not-a-uuid") # => false
      #
      def uuid_format?(value)
        value.match?(UUID_REGEX)
      end
    end
  end
end
