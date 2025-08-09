# frozen_string_literal: true

require "date"
require_relative "../constants/qualification_constants"

module Signetron
  module Validators
    module Helpers
      # Qualification validation helper methods
      #
      # Provides common validation helpers for qualification contract validators.
      # Contains reusable methods for action validation, role validation,
      # UUID format checking, and business rule compatibility validation.
      #
      # @example Using validation helpers in a contract
      #   class QualificationValidator < Dry::Validation::Contract
      #     include Signetron::Validators::Helpers::QualificationHelpers
      #
      #     rule(:action) do
      #       validate_action(key, value)
      #     end
      #
      #     rule(:role) do
      #       validate_role(key, value)
      #     end
      #
      #     rule(:action, :role) do
      #       validate_action_role_compatibility(key, values[:action], values[:role])
      #     end
      #   end
      #
      module QualificationHelpers
        QualificationConstants = Signetron::Validators::Constants::QualificationConstants

        # Validates qualification action value
        #
        # Ensures action is one of the allowed values: 'sign' or 'agree'.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] action value to validate
        #
        # @example Valid action
        #   validate_action(key, "sign")
        #   # No failure added
        #
        # @example Invalid action
        #   validate_action(key, "invalid")
        #   # Adds failure: "must be 'sign' or 'agree'"
        #
        def validate_action(key, value)
          return if QualificationConstants::VALID_ACTIONS_SET.include?(value)

          key.failure(QualificationConstants::VALID_ACTIONS_MESSAGE)
        end

        # Validates qualification role value
        #
        # Ensures role is one of the allowed values: 'signer', 'intervening', or 'witness'.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] role value to validate
        #
        # @example Valid role
        #   validate_role(key, "signer")
        #   # No failure added
        #
        # @example Invalid role
        #   validate_role(key, "invalid")
        #   # Adds failure: "must be 'signer', 'intervening' or 'witness'"
        #
        def validate_role(key, value)
          return if QualificationConstants::VALID_ROLES_SET.include?(value)

          key.failure(QualificationConstants::VALID_ROLES_MESSAGE)
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
        #   validate_uuid_format(key, "invalid-uuid")
        #   # Adds failure: "must be a valid UUID"
        #
        def validate_uuid_format(key, value)
          return if value.match?(QualificationConstants::UUID_REGEX)

          key.failure(QualificationConstants::VALID_UUID_MESSAGE)
        end

        # Validates action and role compatibility
        #
        # Ensures business rule: when action is 'sign', role must be 'signer'.
        # Other action-role combinations are allowed.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param action [String] action value
        # @param role [String] role value
        #
        # @example Valid compatibility
        #   validate_action_role_compatibility(key, "sign", "signer")
        #   validate_action_role_compatibility(key, "agree", "witness")
        #   # No failure added
        #
        # @example Invalid compatibility
        #   validate_action_role_compatibility(key, "sign", "witness")
        #   # Adds failure: "when action is 'sign', role must be 'signer'"
        #
        def validate_action_role_compatibility(key, action, role)
          return unless action == "sign" && role != "signer"

          key.failure(QualificationConstants::ACTION_ROLE_COMPATIBILITY_MESSAGE)
        end
      end
    end
  end
end
