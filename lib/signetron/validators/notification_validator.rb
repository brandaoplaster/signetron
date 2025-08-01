# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    # Notification validation contract for messaging
    #
    # Validates notification message data with minimal requirements.
    # Ensures that if a message is provided, it contains meaningful content
    # and is not just whitespace.
    #
    # @example Valid notification data
    #   validator = NotificationValidator.new
    #   result = validator.call(message: "Please review and sign the document")
    #   result.success? # => true
    #
    # @example Valid notification data (no message)
    #   result = validator.call({})
    #   result.success? # => true
    #
    # @example Valid notification data (nil message)
    #   result = validator.call(message: nil)
    #   result.success? # => true
    #
    # @example Invalid notification data
    #   result = validator.call(message: "   ")
    #   result.success? # => false
    #   result.errors.to_h # => { message: ["must not be empty"] }
    #
    class NotificationValidator < Dry::Validation::Contract
      # Parameter schema definition
      #
      # Message is optional and can be nil, but if provided as a string,
      # it must contain meaningful content (not just whitespace).
      params do
        optional(:message).maybe(:string)
      end

      # Validates message content when provided
      #
      # Allows nil or missing message, but if a string is provided,
      # it must not be empty or contain only whitespace.
      #
      # @example Valid messages
      #   nil # => valid (no message)
      #   "Please sign this document" # => valid
      #   "Reminder: Contract expires tomorrow" # => valid
      #
      # @example Invalid messages
      #   "" # => "must not be empty"
      #   "   " # => "must not be empty"
      #   "\t\n  " # => "must not be empty"
      #
      rule(:message) do
        key.failure("must not be empty") if key? && value && value.strip.empty?
      end
    end
  end
end
