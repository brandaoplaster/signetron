# frozen_string_literal: true

module Signetron
  module Models
    class Signer < Base
      def email
        @attributes[:email]
      end

      def name
        @attributes[:name]
      end

      def phone_number
        @attributes[:phone_number]
      end

      def documentation
        @attributes[:documentation]
      end

      def birthday
        @attributes[:birthday]
      end

      def auths
        @attributes[:auths] || []
      end

      def has_documentation
        @attributes[:has_documentation]
      end

      def selfie_enabled
        @attributes[:selfie_enabled]
      end

      def handwritten_enabled
        @attributes[:handwritten_enabled]
      end

      def official_document_enabled
        @attributes[:official_document_enabled]
      end

      def liveness_enabled
        @attributes[:liveness_enabled]
      end

      def facial_biometrics_enabled
        @attributes[:facial_biometrics_enabled]
      end

      def full_name
        name
      end

      def first_name
        name.split.first if name
      end

      def last_name
        name.split[1..-1].join(" ") if name && name.split.length > 1
      end

      def has_phone?
        !phone_number.nil? && !phone_number.strip.empty?
      end

      def has_documentation?
        has_documentation == true
      end

      def email_auth_enabled?
        auths.include?("email")
      end

      def sms_auth_enabled?
        auths.include?("sms")
      end

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

      def validator
        @validator ||= Validators::SignerValidator.new
      end

      def filter_nil_values(hash)
        hash.reject { |_, value| value.nil? }
      end
    end
  end
end
