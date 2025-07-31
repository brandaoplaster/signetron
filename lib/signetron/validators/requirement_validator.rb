# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    class RequirementValidator < Dry::Validation::Contract
      VALID_ACTIONS = %w[provide_evidence].freeze
      VALID_AUTHS = %w[email sms].freeze
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

      params do
        required(:action).filled(:string)
        required(:auth).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      rule(:action) do
        key.failure("must be 'provide_evidence'") unless VALID_ACTIONS.include?(value)
      end

      rule(:auth) do
        key.failure("must be 'email', 'sms', 'selfie' or 'pix'") unless VALID_AUTHS.include?(value)
      end

      rule(:document_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      rule(:signer_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      private

      def uuid_format?(value)
        value.match?(UUID_REGEX)
      end
    end
  end
end
