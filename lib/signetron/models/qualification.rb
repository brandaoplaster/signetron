# frozen_string_literal: true

module Signetron
  module Models
    class Qualification < Base
      def action
        @attributes[:action]
      end

      def role
        @attributes[:role]
      end

      def document_id
        @attributes[:document_id]
      end

      def signer_id
        @attributes[:signer_id]
      end

      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "requirements",
            attributes: filter_nil_values(@attributes.except(:document_id, :signer_id)),
            relationships: {
              document: {
                data: {
                  type: "documents",
                  id: document_id,
                },
              },
              signer: {
                data: {
                  type: "signers",
                  id: signer_id,
                },
              },
            },
          },
        }
      end

      def self.build(attributes = {})
        new(attributes)
      rescue ValidationError => e
        instance = allocate
        instance.instance_variable_set(:@attributes, {})
        instance.instance_variable_set(:@errors, e.errors)
        instance
      end

      private

      def validator
        @validator ||= Validators::QualificationValidator.new
      end

      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
