# frozen_string_literal: true

module Signetron
  module Models
    # Qualification model for signer roles and document actions
    #
    # Represents a qualification that defines a signer's role and the specific
    # action they can perform on a document. Similar to Requirement but focuses
    # on role-based permissions and qualifications.
    #
    # @example Creating a qualification
    #   qualification = Qualification.new(
    #     action: "approve",
    #     role: "manager",
    #     document_id: "doc_123",
    #     signer_id: "signer_456"
    #   )
    #
    # @example Building qualification with error handling
    #   qualification = Qualification.build(action: "", role: nil)
    #   qualification.valid? # => false
    #   qualification.errors_hash # => { action: ["can't be blank"], role: ["is required"] }
    #
    class Qualification < Base
      # Returns the qualified action type
      #
      # @return [String, nil] the action the signer is qualified to perform (e.g., "approve", "witness", "notarize")
      #
      # @example
      #   qualification.action # => "approve"
      #
      def action
        @attributes[:action]
      end

      # Returns the signer's role
      #
      # @return [String, nil] the role or title of the signer (e.g., "manager", "witness", "notary")
      #
      # @example
      #   qualification.role # => "manager"
      #
      def role
        @attributes[:role]
      end

      # Returns the associated document ID
      #
      # @return [String, nil] identifier of the document for this qualification
      #
      # @example
      #   qualification.document_id # => "doc_123"
      #
      def document_id
        @attributes[:document_id]
      end

      # Returns the associated signer ID
      #
      # @return [String, nil] identifier of the qualified signer
      #
      # @example
      #   qualification.signer_id # => "signer_456"
      #
      def signer_id
        @attributes[:signer_id]
      end

      # Converts qualification to JSON API format with relationships
      #
      # Note: Uses "requirements" type in JSON API for compatibility,
      # but excludes document_id and signer_id from attributes as they
      # are represented in relationships.
      #
      # @return [Hash] qualification data in JSON API specification format
      # @raise [ValidationError] if qualification is invalid
      #
      # @example Valid qualification conversion
      #   qualification.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "requirements",
      #   #     attributes: {
      #   #       action: "approve",
      #   #       role: "manager"
      #   #     },
      #   #     relationships: {
      #   #       document: {
      #   #         data: { type: "documents", id: "doc_123" }
      #   #       },
      #   #       signer: {
      #   #         data: { type: "signers", id: "signer_456" }
      #   #       }
      #   #     }
      #   #   }
      #   # }
      #
      # @example Invalid qualification raises error
      #   qualification = Qualification.new(action: "", role: nil)
      #   qualification.to_json_api # => raises ValidationError
      #
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "requirements",
            attributes: filter_nil_values(@attributes.except(:document_id, :signer_id)),
            relationships: {
              document: { data: { type: "documents", id: document_id } },
              signer: { data: { type: "signers", id: signer_id } },
            },
          },
        }
      end

      # Builds qualification instance without raising validation errors
      #
      # Creates a qualification instance even when validation fails, allowing
      # inspection of validation errors without exception handling.
      #
      # @param attributes [Hash] qualification attributes
      # @return [Qualification] qualification instance (valid or invalid)
      #
      # @example Building valid qualification
      #   qualification = Qualification.build(action: "approve", role: "manager")
      #   qualification.valid? # => true
      #
      # @example Building invalid qualification
      #   qualification = Qualification.build(action: "", role: nil)
      #   qualification.valid? # => false
      #   qualification.errors_hash # => { action: ["can't be blank"], role: ["is required"] }
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

      # Returns the validator contract for qualification validation
      #
      # @return [Validators::QualificationValidator] validator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::QualificationValidator.new
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
