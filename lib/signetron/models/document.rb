# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Models
    class Document < Base
      def filename
        @attributes[:filename]
      end

      def content_base64
        @attributes[:content_base64]
      end

      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "documents",
            attributes: {
              filename: filename,
              content_base64: content_base64,
            },
          },
        }
      end

      private

      def validator
        @validator ||= Validators::DocumentValidator.new
      end
    end
  end
end
