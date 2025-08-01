# frozen_string_literal: true

module Signetron
  module Models
    # Envelope model for document signing workflows
    #
    # Represents a document envelope containing signature requests and configuration
    # for the signing process. Inherits validation and error handling from Base class.
    #
    # @example Creating a valid envelope
    #   envelope = Envelope.new(
    #     name: "Contract Agreement",
    #     locale: "en",
    #     sequence_enabled: true,
    #     auto_close: false
    #   )
    #
    # @example Building envelope with error handling
    #   envelope = Envelope.build(name: "", locale: "invalid")
    #   envelope.valid? # => false
    #   envelope.errors_hash # => { name: ["can't be blank"], locale: ["is invalid"] }
    #
    class Envelope < Base
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
      # @return [String, nil] the locale code for the envelope
      #
      # @example
      #   envelope.locale # => "en"
      #
      def locale
        @attributes[:locale]
      end

      # Returns whether sequence is enabled for signing
      #
      # @return [Boolean, nil] true if signers must sign in sequence
      #
      # @example
      #   envelope.sequence_enabled # => true
      #
      def sequence_enabled
        @attributes[:sequence_enabled]
      end

      # Returns auto-close configuration
      #
      # @return [Boolean, nil] true if envelope should auto-close after all signatures
      #
      # @example
      #   envelope.auto_close # => false
      #
      def auto_close
        @attributes[:auto_close]
      end

      # Returns block after refusal setting
      #
      # @return [Boolean, nil] true if envelope should be blocked after refusal
      #
      # @example
      #   envelope.block_after_refusal # => true
      #
      def block_after_refusal
        @attributes[:block_after_refusal]
      end

      # Returns the envelope deadline
      #
      # @return [Time, String, nil] deadline for completing the envelope
      #
      # @example
      #   envelope.deadline_at # => "2024-12-31T23:59:59Z"
      #
      def deadline_at
        @attributes[:deadline_at]
      end

      # Returns reminder interval configuration
      #
      # @return [Integer, nil] interval in days for sending reminders
      #
      # @example
      #   envelope.remind_interval # => 3
      #
      def remind_interval
        @attributes[:remind_interval]
      end

      # Returns external identifier
      #
      # @return [String, nil] external system identifier for the envelope
      #
      # @example
      #   envelope.external_id # => "ext_12345"
      #
      def external_id
        @attributes[:external_id]
      end

      # Converts envelope to JSON API format
      #
      # @return [Hash] envelope data in JSON API specification format
      # @raise [ValidationError] if envelope is invalid
      #
      # @example Valid envelope conversion
      #   envelope.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "envelopes",
      #   #     attributes: {
      #   #       name: "Contract Agreement",
      #   #       locale: "en",
      #   #       sequence_enabled: true
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
      # @return [Envelope] envelope instance (valid or invalid)
      #
      # @example Building valid envelope
      #   envelope = Envelope.build(name: "Contract", locale: "en")
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
        instance.instance_variable_set(:@attributes, {})
        instance.instance_variable_set(:@errors, e.errors)
        instance
      end

      private

      # Returns the validator contract for envelope validation
      #
      # @return [Validators::EnvelopeValidator] validator instance
      #
      def validator
        @validator ||= Validators::EnvelopeValidator.new
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
