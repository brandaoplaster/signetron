# frozen_string_literal: true

module Signetron
  module Models
    # Notification model for messaging and alerts
    #
    # Represents a notification message that can be sent to users during
    # the signing process. Used for custom messages, alerts, and status
    # updates in envelope workflows.
    #
    # @example Creating a notification
    #   notification = Notification.new(
    #     message: "Please review and sign the contract by end of day"
    #   )
    #
    # @example Building notification with error handling
    #   notification = Notification.build(message: "")
    #   notification.valid? # => false
    #   notification.errors_hash # => { message: ["can't be blank"] }
    #
    class Notification < Base
      # Returns the notification message
      #
      # @return [String, nil] the message content to be sent to users
      #
      # @example
      #   notification.message # => "Please review and sign the contract by end of day"
      #
      def message
        @attributes[:message]
      end

      # Converts notification to JSON API format
      #
      # @return [Hash] notification data in JSON API specification format
      # @raise [ValidationError] if notification is invalid
      #
      # @example Valid notification conversion
      #   notification.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "notifications",
      #   #     attributes: {
      #   #       message: "Please review and sign the contract by end of day"
      #   #     }
      #   #   }
      #   # }
      #
      # @example Invalid notification raises error
      #   notification = Notification.new(message: "")
      #   notification.to_json_api # => raises ValidationError
      #
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "notifications",
            attributes: filter_nil_values(@attributes),
          },
        }
      end

      # Builds notification instance without raising validation errors
      #
      # Creates a notification instance even when validation fails, allowing
      # inspection of validation errors without exception handling.
      #
      # @param attributes [Hash] notification attributes
      # @return [Notification] notification instance (valid or invalid)
      #
      # @example Building valid notification
      #   notification = Notification.build(message: "Document ready for signing")
      #   notification.valid? # => true
      #
      # @example Building invalid notification
      #   notification = Notification.build(message: "")
      #   notification.valid? # => false
      #   notification.errors_hash # => { message: ["can't be blank"] }
      #
      def self.build(attributes = {})
        new(attributes)
      rescue ValidationError => e
        instance = allocate
        instance.instance_variable_set(:@attributes, {})
        instance.instance_variable_set(:@errors, e.errors)
        instance
      end

      private

      # Returns the validator contract for notification validation
      #
      # @return [Validators::NotificationValidator] validator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::NotificationValidator.new
      end

      # Filters out nil values from hash
      #
      # @param hash [Hash] hash to filter
      # @return [Hash] hash without nil values
      #
      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
