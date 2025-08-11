# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    module Constants
      # Requirement validation constants
      #
      # Contains all validation constants for signer requirements
      # including valid actions, authentication methods, validation patterns,
      # and error messages for requirement data validation.
      #
      # @example Using validation constants
      #   # Check if action is valid
      #   action = "provide_evidence"
      #   valid = RequirementConstants::VALID_ACTIONS_SET.include?(action)
      #
      #   # Check if auth method is valid
      #   auth = "email"
      #   valid_auth = RequirementConstants::VALID_AUTHS_SET.include?(auth)
      #
      #   # Validate UUID format
      #   uuid = "550e8400-e29b-41d4-a716-446655440000"
      #   valid_format = uuid.match?(RequirementConstants::UUID_REGEX)
      #
      module RequirementConstants
        # Valid actions for requirements
        VALID_ACTIONS = %w[provide_evidence].freeze

        # Valid authentication methods for requirements
        VALID_AUTHS = %w[email sms].freeze

        # Sets for fast validation lookup
        VALID_ACTIONS_SET = VALID_ACTIONS.to_set.freeze
        VALID_AUTHS_SET = VALID_AUTHS.to_set.freeze

        # UUID format validation pattern
        UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

        # Error messages for validation
        VALID_ACTIONS_MESSAGE = "must be 'provide_evidence'"
        VALID_AUTHS_MESSAGE = "must be 'email', 'sms'"
        VALID_UUID_MESSAGE = "must be a valid UUID"
      end
    end
  end
end
