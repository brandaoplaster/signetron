# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    class QualificationValidator < Dry::Validation::Contract
      VALID_ACTIONS = %w[sign agree].freeze
      VALID_ROLES = %w[signer intervening witness].freeze
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      params do
        required(:action).filled(:string)
        required(:role).filled(:string)
        required(:document_id).filled(:string)
        required(:signer_id).filled(:string)
      end

      rule(:action) do
        key.failure("must be 'sign' or 'agree'") unless VALID_ACTIONS.include?(value)
      end

      rule(:role) do
        key.failure("must be 'signer', 'intervening' or 'witness'") unless VALID_ROLES.include?(value)
      end

      rule(:document_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      rule(:signer_id) do
        key.failure("must be a valid UUID") unless uuid_format?(value)
      end

      rule(:action, :role) do
        if values[:action] == "sign" && values[:role] != "signer"
          key.failure("when action is 'sign', role must be 'signer'")
        end
      end

      private

      def uuid_format?(value)
        value.match?(UUID_REGEX)
      end

      def valid_page_list?(value)
        value.split(",").all? { |page| page.strip.match?(/\A\d+\z/) }
      end
    end
  end
end
