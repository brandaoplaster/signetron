# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Models
    # Document model for file attachments in signing workflows
    #
    # Represents a document file with base64 encoded content that can be
    # attached to envelopes for signing. Inherits validation and error
    # handling from Base class.
    #
    # @example Creating a document
    #   document = Document.new(
    #     filename: "contract.pdf",
    #     content_base64: "JVBERi0xLjQKJcOkw7zDtsO4..."
    #   )
    #
    # @example Converting to JSON API format
    #   document.to_json_api
    #   # => {
    #   #   data: {
    #   #     type: "documents",
    #   #     attributes: {
    #   #       filename: "contract.pdf",
    #   #       content_base64: "JVBERi0xLjQKJcOkw7zDtsO4..."
    #   #     }
    #   #   }
    #   # }
    #
    class Document < Base
      # Returns the document filename
      #
      # @return [String, nil] the filename of the document
      #
      # @example
      #   document.filename # => "contract.pdf"
      #
      def filename
        @attributes[:filename]
      end

      # Returns the base64 encoded document content
      #
      # @return [String, nil] the document content encoded in base64
      #
      # @example
      #   document.content_base64 # => "JVBERi0xLjQKJcOkw7zDtsO4..."
      #
      def content_base64
        @attributes[:content_base64]
      end

      # Converts document to JSON API format
      #
      # @return [Hash] document data in JSON API specification format
      # @raise [ValidationError] if document is invalid
      #
      # @example Valid document conversion
      #   document.to_json_api
      #   # => {
      #   #   data: {
      #   #     type: "documents",
      #   #     attributes: {
      #   #       filename: "contract.pdf",
      #   #       content_base64: "JVBERi0xLjQKJcOkw7zDtsO4..."
      #   #     }
      #   #   }
      #   # }
      #
      # @example Invalid document raises error
      #   document = Document.new(filename: "", content_base64: "")
      #   document.to_json_api # => raises ValidationError
      #
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

      # Returns the validator contract for document validation
      #
      # @return [Validators::DocumentValidator] validator instance
      #
      # :reek:UnusedPrivateMethod
      def validator
        @validator ||= Validators::DocumentValidator.new
      end
    end
  end
end
