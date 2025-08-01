# frozen_string_literal: true

module Signetron
  module Models
    ##
    # Signer model for document signing participants
    #
    # Represents a person who will sign documents in an envelope.
    # Contains only essential attributes and methods based on API requirements.
    #
    # Example:
    #   signer = Signer.new(
    #     name: "John Doe",
    #     email: "john@example.com",
    #     phone_number: "+1234567890",
    #     has_documentation: true,
    #     documentation: "123.456.789-00",
    #     birthday: "1990-05-15"
    #   )
    #
    class Signer < Base
      ##
      # Returns the signer's full name
      #
      # Returns:: String with complete name of the signer
      #
      def name
        @attributes[:name]
      end

      ##
      # Returns the signer's email address
      #
      # Returns:: String with email address or nil
      #
      def email
        @attributes[:email]
      end

      ##
      # Returns the signer's phone number
      #
      # Returns:: String with phone number or nil
      #
      def phone_number
        @attributes[:phone_number]
      end

      ##
      # Returns whether signer documentation is required
      #
      # Returns:: Boolean indicating if documentation is required
      #
      def documentation_required?
        @attributes[:has_documentation]
      end

      ##
      # Returns the signer's CPF documentation
      #
      # Returns:: String with CPF number or nil
      #
      def documentation
        @attributes[:documentation]
      end

      ##
      # Returns the signer's birthday
      #
      # Returns:: Date or String with birth date or nil
      #
      def birthday
        @attributes[:birthday]
      end

      ##
      # Returns whether signer can refuse the document
      #
      # Returns:: Boolean indicating if signer can refuse
      #
      def refusable
        @attributes[:refusable]
      end

      ##
      # Returns the signer's group number for signing order
      #
      # Returns:: Integer with group number
      #
      def group
        @attributes[:group]
      end

      ##
      # Returns whether location sharing is required
      #
      # Returns:: Boolean indicating if location is required
      #
      def location_required_enabled
        @attributes[:location_required_enabled]
      end

      ##
      # Returns communication events configuration
      #
      # Returns:: CommunicateEvents instance or nil
      #
      def communicate_events
        return nil unless @attributes[:communicate_events]

        @communicate_events ||= CommunicateEvents.new(@attributes[:communicate_events])
      end

      ##
      # Converts signer to JSON API format
      #
      # Returns:: Hash with signer data in JSON API specification format
      #
      # Raises::
      #   ValidationError:: if signer is invalid
      #
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "signers",
            attributes: filter_nil_values(@attributes),
          },
        }
      end

      private

      ##
      # Returns the validator contract for signer validation
      #
      # Returns:: Validators::SignerValidator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::SignerValidator.new
      end

      ##
      # Filters out nil values from hash
      #
      # Args:
      #   hash:: Hash to filter
      #
      # Returns:: Hash without nil values
      #
      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
