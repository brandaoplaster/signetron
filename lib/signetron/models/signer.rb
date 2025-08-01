# frozen_string_literal: true

module Signetron
  module Models
    # Signer model for document signing participants
    #
    # Represents a person who will sign documents in an envelope, including
    # their personal information, authentication methods, and security settings.
    # Inherits validation and error handling from Base class.
    #
    # @example Creating a signer
    #   signer = Signer.new(
    #     email: "john@example.com",
    #     name: "John Doe",
    #     phone_number: "+1234567890",
    #     auths: ["email", "sms"],
    #     selfie_enabled: true
    #   )
    #
    # @example Checking authentication methods
    #   signer.email_auth_enabled? # => true
    #   signer.sms_auth_enabled?   # => true
    #
    class Signer < Base
      # Returns the signer's email address
      #
      # @return [String, nil] email address for notifications and authentication
      #
      # @example
      #   signer.email # => "john@example.com"
      #
      def email
        @attributes[:email]
      end

      # Returns the signer's full name
      #
      # @return [String, nil] complete name of the signer
      #
      # @example
      #   signer.name # => "John Doe"
      #
      def name
        @attributes[:name]
      end

      # Returns the signer's phone number
      #
      # @return [String, nil] phone number for SMS notifications and authentication
      #
      # @example
      #   signer.phone_number # => "+1234567890"
      #
      def phone_number
        @attributes[:phone_number]
      end

      # Returns the signer's documentation number
      #
      # @return [String, nil] government ID or documentation number
      #
      # @example
      #   signer.documentation # => "123.456.789-00"
      #
      def documentation
        @attributes[:documentation]
      end

      # Returns the signer's birthday
      #
      # @return [Date, String, nil] date of birth
      #
      # @example
      #   signer.birthday # => "1990-05-15"
      #
      def birthday
        @attributes[:birthday]
      end

      # Returns enabled authentication methods
      #
      # @return [Array<String>] list of authentication methods (email, sms, etc.)
      #
      # @example
      #   signer.auths # => ["email", "sms"]
      #
      def auths
        @attributes[:auths] || []
      end

      # Returns whether signer has documentation
      #
      # @return [Boolean, nil] true if signer has provided documentation
      #
      def has_documentation
        @attributes[:has_documentation]
      end

      # Returns selfie verification setting
      #
      # @return [Boolean, nil] true if selfie verification is enabled
      #
      def selfie_enabled
        @attributes[:selfie_enabled]
      end

      # Returns handwritten signature setting
      #
      # @return [Boolean, nil] true if handwritten signatures are enabled
      #
      def handwritten_enabled
        @attributes[:handwritten_enabled]
      end

      # Returns official document verification setting
      #
      # @return [Boolean, nil] true if official document verification is enabled
      #
      def official_document_enabled
        @attributes[:official_document_enabled]
      end

      # Returns liveness detection setting
      #
      # @return [Boolean, nil] true if liveness detection is enabled
      #
      def liveness_enabled
        @attributes[:liveness_enabled]
      end

      # Returns facial biometrics setting
      #
      # @return [Boolean, nil] true if facial biometrics verification is enabled
      #
      def facial_biometrics_enabled
        @attributes[:facial_biometrics_enabled]
      end

      # Returns the signer's full name (alias for name)
      #
      # @return [String, nil] complete name of the signer
      #
      # @example
      #   signer.full_name # => "John Doe"
      #
      def full_name
        name
      end

      # Extracts first name from full name
      #
      # @return [String, nil] first name only
      #
      # @example
      #   signer.first_name # => "John"
      #
      def first_name
        name.split.first if name
      end

      # Extracts last name from full name
      #
      # @return [String, nil] last name(s) joined with spaces
      #
      # @example
      #   signer = Signer.new(name: "John Michael Doe")
      #   signer.last_name # => "Michael Doe"
      #
      def last_name
        name.split[1..-1].join(" ") if name && name.split.length > 1
      end

      # Checks if signer has a valid phone number
      #
      # @return [Boolean] true if phone number exists and is not empty
      #
      # @example
      #   signer.has_phone? # => true
      #
      def has_phone?
        !phone_number.nil? && !phone_number.strip.empty?
      end

      # Checks if signer has documentation enabled
      #
      # @return [Boolean] true if has_documentation is explicitly true
      #
      # @example
      #   signer.has_documentation? # => true
      #
      def has_documentation?
        has_documentation == true
      end

      # Checks if email authentication is enabled
      #
      # @return [Boolean] true if "email" is in the auths array
      #
      # @example
      #   signer.email_auth_enabled? # => true
      #
      def email_auth_enabled?
        auths.include?("email")
      end

      # Checks if SMS authentication is enabled
      #
      # @return [Boolean] true if "sms" is in the auths array
      #
      # @example
      #   signer.sms_auth_enabled? # => true
      #
      def sms_auth_enabled?
        auths.include?("sms")
      end

      # Converts signer to JSON API format
      #
      # @return [Hash] signer data in JSON API specification format
      # @raise [ValidationError] if signer is invalid
      #
      # @example Valid signer conversion
      #   signer.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "signers",
      #   #     attributes: {
      #   #       email: "john@example.com",
      #   #       name: "John Doe",
      #   #       auths: ["email", "sms"]
      #   #     }
      #   #   }
      #   # }
      #
      # @example Invalid signer raises error
      #   signer = Signer.new(email: "invalid")
      #   signer.to_json_api # => raises ValidationError
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

      # Returns the validator contract for signer validation
      #
      # @return [Validators::SignerValidator] validator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::SignerValidator.new
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
