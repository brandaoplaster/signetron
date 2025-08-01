# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Qualification validation contract for signer roles and actions
    #
    # Validates qualification data that defines what actions a signer can
    # perform and their role in the document signing process. Enforces
    # business rules like action-role compatibility and proper UUID formatting.
    #
    # @example Valid qualification data
    #   validator = QualificationValidator.new
    #   result = validator.call(
    #     action: "sign",
    #     role: "signer",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "123e4567-e89b-12d3-a456-426614174000"
    #   )
    #   result.success? # => true
    #
    # @example Invalid qualification data (action-role mismatch)
    #   result = validator.call(
    #     action: "sign",
    #     role: "witness",
    #     document_id: "550e8400-e29b-41d4-a716-446655440000",
    #     signer_id: "123e4567-e89b-12d3-a456-426614174000"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { action: ["when action is 'sign', role must be 'signer'"] }
    #
    class QualificationValidator < Dry::Validation::Contract
      # Valid qualification actions supported by the system
      VALID_ACTIONS = %w[sign agree].freeze

      # Valid signer roles in the document workflow
      VALID_ROLES = %w[signer intervening witness].freeze

      # UUID format validation regex (RFC 4122 compliant)
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

      # Parameter schema definition
      #
      # All parameters are required and must be non-empty strings.
      # Document and signer references must be valid UUIDs.
      params do
        required(:action).filled(:string)
        required(:role).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      # Validates qualification action is supported
      #
      # @example Valid actions
      #   "sign" # => valid
      #   "agree" # => valid
      #
      # @example Invalid actions
      #   "approve" # => "must be 'sign' or 'agree'"
      #   "witness" # => "must be 'sign' or 'agree'"
      #   "" # => "must be 'sign' or 'agree'"
      #
      rule(:action) do
        key.failure("must be 'sign' or 'agree'") unless VALID_ACTIONS.include?(value)
      end

      # Validates signer role is supported
      #
      # @example Valid roles
      #   "signer" # => valid
      #   "intervening" # => valid
      #   "witness" # => valid
      #
      # @example Invalid roles
      #   "notary" # => "must be 'signer', 'intervening' or 'witness'"
      #   "approver" # => "must be 'signer', 'intervening' or 'witness'"
      #
      rule(:role) do
        key.failure("must be 'signer', 'intervening' or 'witness'") unless VALID_ROLES.include?(value)
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
      #
      rule(:signer_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      # Validates action-role compatibility
      #
      # Enforces business rule that only signers can perform sign actions.
      # Other roles (intervening, witness) can only perform agree actions.
      #
      # @example Valid action-role combinations
      #   action: "sign", role: "signer" # => valid
      #   action: "agree", role: "witness" # => valid
      #   action: "agree", role: "intervening" # => valid
      #   action: "agree", role: "signer" # => valid
      #
      # @example Invalid action-role combinations
      #   action: "sign", role: "witness" # => "when action is 'sign', role must be 'signer'"
      #   action: "sign", role: "intervening" # => "when action is 'sign', role must be 'signer'"
      #
      rule(:action, :role) do
        if values[:action] == "sign" && values[:role] != "signer"
          key.failure("when action is 'sign', role must be 'signer'")
        end
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

      # Validates comma-separated page numbers format
      #
      # Note: This method is defined but not used in current validation rules.
      # May be intended for future use with page-specific qualifications.
      #
      # @param value [String] comma-separated page numbers
      # @return [Boolean] true if all values are valid page numbers
      #
      # @example
      #   valid_page_list?("1,2,3") # => true
      #   valid_page_list?("1, 5, 10") # => true
      #   valid_page_list?("1,invalid,3") # => false
      #
      def valid_page_list?(value)
        value.split(",").all? { |page| page.strip.match?(/\A\d+\z/) }
      end
    end
  end
end
