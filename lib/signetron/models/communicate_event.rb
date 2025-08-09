# frozen_string_literal: true

module Signetron
  module Models
    # Communication events configuration for signer notifications
    #
    # Represents notification preferences for different stages of the signing process.
    # Inherits validation and error handling from Base class. Validates event
    # configuration before sending to Signetron API.
    #
    #   events = CommunicateEvents.new
    #   events.signature_request # => "email"
    #   events.signature_reminder # => "email"
    #   events.document_signed # => "email"
    #
    #   events = CommunicateEvents.new(
    #     signature_request: "whatsapp",
    #     signature_reminder: "none",
    #     document_signed: "email"
    #   )
    #   events.valid? # => true
    #
    #   events = CommunicateEvents.build(signature_request: "invalid")
    #   events.valid? # => false
    #   events.errors_hash # => { signature_request: ["must be one of: email, sms, whatsapp, none"] }
    #
    class CommunicateEvents < Base
      # Valid values for signature request communication
      SIGNATURE_REQUEST_VALUES = %w[email sms whatsapp none].freeze

      # Valid values for signature reminder communication
      SIGNATURE_REMINDER_VALUES = %w[none email].freeze

      # Valid values for document signed communication
      DOCUMENT_SIGNED_VALUES = %w[email whatsapp].freeze

      # Returns signature request communication method
      #
      # Indicates how should communicate signature requests to signers.
      # Defaults to email if not specified.
      #
      # Valid values: email, sms, whatsapp, none
      def signature_request
        @attributes[:signature_request] || "email"
      end

      # Returns signature reminder communication method
      #
      # Determines how reminders are delivered according to the interval
      # configured in the remind_interval attribute during envelope creation.
      #
      # Valid values: none, email
      def signature_reminder
        @attributes[:signature_reminder] || "email"
      end

      # Returns document signed communication method
      #
      # Indicates how should communicate to signers when
      # the document has been signed by all signatories.
      #
      # Valid values: email, whatsapp
      def document_signed
        @attributes[:document_signed] || "email"
      end

      # Checks if any event requires email communication
      #
      # Determines if email address is required for the signer based on
      # the configured communication events.
      def requires_email?
        [signature_request, signature_reminder, document_signed].include?("email")
      end

      # Checks if any event requires phone communication
      #
      # Determines if phone number is required for the signer based on
      # SMS or WhatsApp communication events.
      def requires_phone?
        [signature_request, signature_reminder, document_signed].any? { |v| %w[sms whatsapp].include?(v) }
      end

      # Checks if any event uses SMS communication
      def uses_sms?
        [signature_request, signature_reminder, document_signed].include?("sms")
      end

      # Checks if any event uses WhatsApp communication
      def uses_whatsapp?
        [signature_request, signature_reminder, document_signed].include?("whatsapp")
      end

      # Converts communication events to JSON API format
      #
      # Validates the communication events and converts to JSON API specification
      # format for sending to the Signetron API. Only proceeds if validation passes.
      #
      # Raises ValidationError if communication events are invalid.
      #
      #   events = CommunicateEvents.new(signature_request: "email")
      #   events.to_json_api
      #   # => {
      #   #   signature_request: "email",
      #   #   signature_reminder: "email",
      #   #   document_signed: "email"
      #   # }
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          signature_request: signature_request,
          signature_reminder: signature_reminder,
          document_signed: document_signed,
        }
      end

      # Builds communication events instance without raising validation errors
      #
      # Creates a communication events instance even when validation fails,
      # allowing inspection of validation errors without exception handling.
      #
      #   events = CommunicateEvents.build(signature_request: "email")
      #   events.valid? # => true
      #
      #   events = CommunicateEvents.build(signature_request: "invalid")
      #   events.valid? # => false
      #   events.errors_hash # => { signature_request: ["must be one of: email, sms, whatsapp, none"] }
      def self.build(attributes = {})
        new(attributes)
      rescue ValidationError => e
        instance = allocate
        instance.instance_variable_set(:@attributes, attributes)
        instance.instance_variable_set(:@errors, e.errors)
        instance
      end

      private

      # Returns the validator contract for communication events validation
      #
      # Lazy-loads the communication events validator instance for validating
      # event attributes according to business rules.
      def validator
        @validator ||= Validators::CommunicateEventsValidator.new
      end
    end
  end
end
