# frozen_string_literal: true

require "date"

module Signetron
  module Models
    # Document envelope for signature workflows
    #
    # Represents a document envelope containing signature requests and configuration
    # for the signing process. Inherits validation and error handling from Base class.
    # Validates envelope data before sending to Signetron API.
    #
    # @author Signetron Team
    # @since 1.0.0
    #
    # @example Creating a valid envelope
    #   envelope = Envelope.new(
    #     name: "Contract Agreement",
    #     locale: "pt-BR",
    #     auto_close: false
    #   )
    #   envelope.valid? # => true
    #
    # @example Building envelope with error handling
    #   envelope = Envelope.build(name: "", locale: "invalid")
    #   envelope.valid? # => false
    #   envelope.errors_hash # => { name: ["can't be blank"], locale: ["is invalid"] }
    #
    class Envelope < Base
      def initialize(attributes = {})
        super(apply_defaults(attributes))
      end

      # Returns the envelope name
      #
      # @return [String, nil] the name of the envelope
      #
      # @example
      #   envelope.name # => "Contract Agreement"
      #
      def name
        @attributes[:name]
      end

      # Returns the envelope locale
      #
      # Language code that determines document language. Affects emails,
      # signature pages, and signed document logs.
      #
      # @return [String, nil] the locale code for the envelope
      #
      # @example
      #   envelope.locale # => "pt-BR"
      #
      def locale
        @attributes[:locale]
      end

      # Returns the envelope status
      #
      # Current lifecycle status of the envelope. Controls envelope activation
      # and is only available during envelope updates.
      #
      # @return [String, nil] current status of the envelope
      # @note Valid values: draft, running, canceled, closed
      #
      # @example
      #   envelope.status # => "draft"
      #
      def status
        @attributes[:status]
      end

      # Returns auto-close configuration
      #
      # Determines if document will be automatically finalized after
      # the last signatory completes their signature.
      #
      # @return [Boolean, nil] true if envelope should auto-close after all signatures
      #
      # @example
      #   envelope.auto_close # => true
      #
      def auto_close
        @attributes[:auto_close]
      end

      # Returns block after refusal setting
      #
      # Determines if the signing process should be paused when
      # a signatory refuses to sign the document.
      #
      # @return [Boolean, nil] true if envelope should be blocked after refusal
      #
      # @example
      #   envelope.block_after_refusal # => false
      #
      def block_after_refusal
        @attributes[:block_after_refusal]
      end

      # Returns the envelope deadline
      #
      # Deadline for completing document signatures. Document will be
      # automatically finalized when deadline is reached. Maximum 90 days from upload.
      #
      # @return [Time, String, nil] deadline for completing the envelope
      # @note Must be greater than current date/time, maximum 90 days from upload
      #
      # @example
      #   envelope.deadline_at # => "2024-12-31T23:59:59Z"
      #
      def deadline_at
        @attributes[:deadline_at]
      end

      # Returns reminder interval configuration
      #
      # Determines if document will have automatic reminders enabled.
      # Up to three reminders will be sent automatically at the specified interval.
      #
      # @return [Integer, nil] interval in days for sending reminders
      # @note Valid values: null, 1, 2, 3, 7, 14
      #
      # @example
      #   envelope.remind_interval # => 3
      #
      def remind_interval
        @attributes[:remind_interval]
      end

      # Returns external identifier
      #
      # External system identifier for envelope integration and tracking.
      #
      # @return [String, nil] external system identifier for the envelope
      #
      # @example
      #   envelope.external_id # => "ext_12345"
      #
      def external_id
        @attributes[:external_id]
      end

      # Returns the default email subject
      #
      # Default subject line for signature request emails sent to signatories.
      # If not provided, a default subject will be used.
      #
      # @return [String, nil] default subject for signature request emails
      # @note Maximum 100 characters
      #
      # @example
      #   envelope.default_subject # => "Please sign this document"
      #
      def default_subject
        @attributes[:default_subject]
      end

      # Returns the default message
      #
      # Default message sent to signatories with signature requests.
      # Can be overridden per signatory when triggering notifications.
      #
      # @return [String, nil] default message sent to signers
      #
      # @example
      #   envelope.default_message # => "Please review and sign the attached document"
      #
      def default_message
        @attributes[:default_message]
      end

      # Converts envelope to JSON API format
      #
      # Validates the envelope and converts it to JSON API specification format
      # for sending to the Signetron API. Only proceeds if validation passes.
      #
      # @return [Hash] envelope data in JSON API specification format
      # @raise [ValidationError] if envelope is invalid
      #
      # @example Valid envelope conversion
      #   envelope = Envelope.new(name: "Contract", locale: "pt-BR")
      #   envelope.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "envelopes",
      #   #     attributes: {
      #   #       name: "Contract",
      #   #       locale: "pt-BR"
      #   #     }
      #   #   }
      #   # }
      #
      # @example Invalid envelope raises error
      #   envelope = Envelope.build(name: "")
      #   envelope.to_json_api # => raises ValidationError
      #
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "envelopes",
            attributes: filter_nil_values(@attributes),
          },
        }
      end

      # Builds envelope instance without raising validation errors
      #
      # Creates an envelope instance even when validation fails, allowing
      # inspection of validation errors without exception handling.
      #
      # @param attributes [Hash] envelope attributes
      # @option attributes [String] :name envelope name (required)
      # @option attributes [String] :locale language code (pt-BR, en-US)
      # @option attributes [Boolean] :auto_close auto-close after signing
      # @return [Envelope] envelope instance (valid or invalid)
      #
      # @example Building valid envelope
      #   envelope = Envelope.build(name: "Contract", locale: "pt-BR")
      #   envelope.valid? # => true
      #
      # @example Building invalid envelope
      #   envelope = Envelope.build(name: "", locale: "invalid")
      #   envelope.valid? # => false
      #   envelope.errors_hash # => { name: ["can't be blank"], locale: ["is invalid"] }
      #
      def self.build(attributes = {})
        new(attributes)
      rescue ValidationError => e
        instance = allocate
        instance.instance_variable_set(:@attributes, attributes)
        instance.instance_variable_set(:@errors, e.errors)
        instance
      end

      private

      def apply_defaults(attributes)
        defaults = {
          locale: "pt-BR",
          auto_close: true,
          block_after_refusal: false,
          remind_interval: 3,
          deadline_at: Date.today + 30,
          default_message: "",
        }
        attributes.reverse_merge!(defaults)
      end

      # Returns the validator contract for envelope validation
      #
      # Lazy-loads the envelope validator instance for validating
      # envelope attributes according to business rules.
      #
      # @return [Validators::EnvelopeValidator] validator instance
      # @api private
      #
      def validator
        @validator ||= Validators::EnvelopeValidator.new
      end

      # Filters out nil values from hash
      #
      # Removes nil values to create clean JSON API payload,
      # ensuring only meaningful attributes are sent to the API.
      #
      # @param hash [Hash] hash to filter
      # @return [Hash] hash without nil values
      # @api private
      #
      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
