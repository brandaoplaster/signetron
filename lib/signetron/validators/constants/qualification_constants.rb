# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    module Constants
      # Qualification validation constants
      #
      # Contains all validation constants for signer qualifications
      # including valid actions, roles, validation patterns, and error
      # messages for qualification data validation.
      #
      # @example Using validation constants
      #   # Check if action is valid
      #   action = "sign"
      #   valid = QualificationConstants::VALID_ACTIONS_SET.include?(action)
      #
      #   # Validate UUID format
      #   uuid = "550e8400-e29b-41d4-a716-446655440000"
      #   valid_format = uuid.match?(QualificationConstants::UUID_REGEX)
      #
      module QualificationConstants
        # Valid actions for qualification
        VALID_ACTIONS = %w[sign agree].freeze

        # Valid roles for qualification
        VALID_ROLES = %w[signer intervening witness].freeze

        # Sets for fast validation lookup
        VALID_ACTIONS_SET = VALID_ACTIONS.to_set.freeze
        VALID_ROLES_SET = VALID_ROLES.to_set.freeze

        # UUID format validation pattern
        UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

        # Error messages for validation
        VALID_ACTIONS_MESSAGE = "must be 'sign' or 'agree'"
        VALID_ROLES_MESSAGE = "must be 'signer', 'intervening' or 'witness'"
        VALID_UUID_MESSAGE = "must be a valid UUID"

        # Error message for business rule validation
        ACTION_ROLE_COMPATIBILITY_MESSAGE = "when action is 'sign', role must be 'signer'"
      end
    end
  end
end
