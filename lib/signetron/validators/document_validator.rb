# frozen_string_literal: true

require "dry-validation"
require_relative "helpers/document_helpers"

module Signetron
  module Validators
    # Document validation contract for file uploads
    #
    # Validates document files including filename format, file extension,
    # base64 encoding, file size limits, and MIME type consistency.
    # Ensures uploaded documents meet security and format requirements.
    #
    # @example Valid document data with data URI
    #   validator = DocumentValidator.new
    #   result = validator.call(
    #     filename: "contract.pdf",
    #     content_base64: "data:application/pdf;base64,JVBERi0xLjQK..."
    #   )
    #   result.success? # => true
    #
    # @example Valid document data with raw base64
    #   result = validator.call(
    #     filename: "image.jpg",
    #     content_base64: "/9j/4AAQSkZJRgABAQEAYABgAAD..."
    #   )
    #   result.success? # => true
    #
    # @example Valid document formats
    #   # PDF document
    #   validator.call(filename: "document.pdf", content_base64: "data:application/pdf;base64,JVBERi0...")
    #   # Word document
    #   validator.call(filename: "document.docx", content_base64: "UEsDBBQABgAIAAAAIQDd...")
    #   # Image file
    #   validator.call(filename: "image.png", content_base64: "data:image/png;base64,iVBORw0KGgoA...")
    #
    # @example Invalid document data
    #   result = validator.call(
    #     filename: "file.exe", # unsupported extension
    #     content_base64: "invalid_base64"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { filename: ["extension must be: pdf, doc, docx, txt, jpg, jpeg, png"],
    #                      #      content_base64: ["invalid Base64"] }
    #
    # @example MIME type mismatch
    #   result = validator.call(
    #     filename: "document.pdf",
    #     content_base64: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD..."
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { content_base64: ["MIME type does not match extension"] }
    #
    class DocumentValidator < Dry::Validation::Contract
      include Signetron::Validators::Helpers::DocumentValidationHelpers

      # Parameter schema definition
      #
      # Both filename and base64 content are required and must be non-empty strings.
      params do
        required(:filename).filled(:string)
        required(:content_base64).filled(:string)
      end

      # Validates filename requirements
      #
      # Checks filename length, invalid characters, and required file extension.
      # Ensures filename meets format and security requirements.
      rule(:filename) do
        validate_filename_format(key, value)
      end

      # Validates base64 content requirements
      #
      # Checks base64 format validity, file size limits, and MIME type consistency
      # with filename extension when data URI format is used.
      rule(:content_base64) do
        validate_base64_content(key, value, values[:filename])
      end
    end
  end
end
