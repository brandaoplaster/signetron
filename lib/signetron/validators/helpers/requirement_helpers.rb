# frozen_string_literal: true

require_relative "../constants/requirement_constants"

module Signetron
  module Validators
    module Helpers
      # Requirement validation helper methods
      #
      # Provides common validation helpers for requirement contract validators.
      # Contains reusable methods for action validation, authentication method
      # validation, and UUID format checking for requirement assignments.
      #
      # @example Using validation helpers in a contract
      #   class RequirementValidator < Dry::Validation::Contract
      #     include Signetron::Validators::Helpers::RequirementValidationHelpers
      #
      #     rule(:action) do
      #       validate_action(key, value)
      #     end
      #
      #     rule(:auth) do
      #       validate_auth(key, value)
      #     end
      #
      #     rule(:signer_id) do
      #       validate_uuid_format(key, value)
      #     end
      #   end
      #
      module RequirementValidationHelpers
        RequirementConstants = Signetron::Validators::Constants::RequirementConstants

        # Validates requirement action value
        #
        # Ensures action is one of the allowed values: 'provide_evidence'.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] action value to validate
        #
        # @example Valid action
        #   validate_action(key, "provide_evidence")
        #   # No failure added
        #
        # @example Invalid action
        #   validate_action(key, "invalid_action")
        #   # Adds failure: "must be 'provide_evidence'"
        #
        def validate_action(key, value)
          return if RequirementConstants::VALID_ACTIONS_SET.include?(value)

          key.failure(RequirementConstants::VALID_ACTIONS_MESSAGE)
        end

        # Validates requirement authentication method
        #
        # Ensures auth method is one of the allowed values: 'email' or 'sms'.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] auth method value to validate
        #
        # @example Valid email auth
        #   validate_auth(key, "email")
        #   # No failure added
        #
        # @example Valid SMS auth
        #   validate_auth(key, "sms")
        #   # No failure added
        #
        # @example Invalid auth method
        #   validate_auth(key, "whatsapp")
        #   # Adds failure: "must be 'email', 'sms'"
        #
        def validate_auth(key, value)
          return if RequirementConstants::VALID_AUTHS_SET.include?(value)

          key.failure(RequirementConstants::VALID_AUTHS_MESSAGE)
        end

        # Validates UUID format
        #
        # Ensures value matches valid UUID pattern (8-4-4-4-12 hex digits).
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] UUID value to validate
        #
        # @example Valid UUID format
        #   validate_uuid_format(key, "550e8400-e29b-41d4-a716-446655440000")
        #   # No failure added
        #
        # @example Invalid UUID format
        #   validate_uuid_format(key, "invalid-uuid-format")
        #   # Adds failure: "must be a valid UUID"
        #
        def validate_uuid_format(key, value)
          key.failure(RequirementConstants::VALID_UUID_MESSAGE) unless value.match?(RequirementConstants::UUID_REGEX)
        end
      end
    end
  end
end
