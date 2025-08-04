# frozen_string_literal: true

module Signetron
  module Models
    # Requirement model for signing actions and relationships
    #
    # Represents a specific requirement that links a signer to a document
    # with a defined action and authentication method. Used to define
    # what each signer must do with each document in an envelope.
    #
    # @example Creating a signature requirement
    #   requirement = Requirement.new(
    #     action: "sign",
    #     auth: "email",
    #     document_id: "doc_123",
    #     signer_id: "signer_456"
    #   )
    #
    # @example Building requirement with error handling
    #   requirement = Requirement.build(action: "", signer_id: nil)
    #   requirement.valid? # => false
    #   requirement.errors_hash # => { action: ["can't be blank"], signer_id: ["is required"] }
    #
    class Requirement < Base
      # Returns the required action type
      #
      # @return [String, nil] the action to be performed (e.g., "sign", "approve", "view")
      #
      # @example
      #   requirement.action # => "sign"
      #
      def action
        @attributes[:action]
      end

      # Returns the authentication method required
      #
      # @return [String, nil] authentication method for this requirement (e.g., "email", "sms")
      #
      # @example
      #   requirement.auth # => "email"
      #
      def auth
        @attributes[:auth]
      end

      # Returns the associated document ID
      #
      # @return [String, nil] identifier of the document to be acted upon
      #
      # @example
      #   requirement.document_id # => "doc_123"
      #
      def document_id
        @attributes[:document_id]
      end

      # Returns the associated signer ID
      #
      # @return [String, nil] identifier of the signer who must perform the action
      #
      # @example
      #   requirement.signer_id # => "signer_456"
      #
      def signer_id
        @attributes[:signer_id]
      end

      # Converts requirement to JSON API format with relationships
      #
      # @return [Hash] requirement data in JSON API specification format including relationships
      # @raise [ValidationError] if requirement is invalid
      #
      # @example Valid requirement conversion
      #   requirement.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "requirements",
      #   #     attributes: {
      #   #       action: "sign",
      #   #       auth: "email"
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
      # @example Invalid requirement raises error
      #   requirement = Requirement.new(action: "", signer_id: nil)
      #   requirement.to_json_api # => raises ValidationError
      #
      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "requirements",
            attributes: { action: action, auth: auth },
            relationships: {
              document: { data: { type: "documents", id: document_id } },
              signer: { data: { type: "signers", id: signer_id } },
            },
          },
        }
      end

      # Builds requirement instance without raising validation errors
      #
      # Creates a requirement instance even when validation fails, allowing
      # inspection of validation errors without exception handling.
      #
      # @param attributes [Hash] requirement attributes
      # @return [Requirement] requirement instance (valid or invalid)
      #
      # @example Building valid requirement
      #   requirement = Requirement.build(action: "sign", signer_id: "signer_123")
      #   requirement.valid? # => true
      #
      # @example Building invalid requirement
      #   requirement = Requirement.build(action: "", signer_id: nil)
      #   requirement.valid? # => false
      #   requirement.errors_hash # => { action: ["can't be blank"], signer_id: ["is required"] }
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

      # Returns the validator contract for requirement validation
      #
      # @return [Validators::RequirementValidator] validator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::RequirementValidator.new
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
