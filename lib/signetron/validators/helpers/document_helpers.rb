# frozen_string_literal: true

require_relative "../constants/document_constants"
require "base64"

module Signetron
  module Validators
    module Helpers
      # Document validation helper methods
      #
      # Provides common validation helpers for document contract validators.
      # Contains reusable methods for filename validation, base64 content
      # validation, file size checking, and MIME type consistency verification.
      #
      # @example Using validation helpers in a contract
      #   class DocumentValidator < Dry::Validation::Contract
      #     include Signetron::Validators::Helpers::DocumentValidationHelpers
      #
      #     rule(:filename) do
      #       validate_filename_format(key, value)
      #     end
      #
      #     rule(:content_base64) do
      #       validate_base64_content(key, value, values[:filename])
      #     end
      #   end
      #
      module DocumentValidationHelpers
        DocumentConstants = Signetron::Validators::Constants::DocumentConstants

        # Extracts base64 content from data URI or returns as-is
        #
        # Removes data URI prefix if present, returning clean base64 content.
        #
        # @param value [String] base64 string with optional data URI prefix
        # @return [String] clean base64 content without data URI prefix
        #
        # @example With data URI
        #   extract_base64_content("data:application/pdf;base64,JVBERi0xLjQK")
        #   # => "JVBERi0xLjQK"
        #
        # @example Raw base64
        #   extract_base64_content("JVBERi0xLjQK")
        #   # => "JVBERi0xLjQK"
        #
        def extract_base64_content(value)
          match = value.match(DocumentConstants::DATA_URI_REGEX)
          match ? match[2] : value
        end

        # Extracts MIME type from data URI
        #
        # Returns MIME type if data URI format is detected, nil otherwise.
        #
        # @param value [String] base64 string with optional data URI prefix
        # @return [String, nil] MIME type or nil if not found
        #
        # @example With data URI
        #   extract_mime_type("data:application/pdf;base64,JVBERi0xLjQK")
        #   # => "application/pdf"
        #
        # @example Raw base64
        #   extract_mime_type("JVBERi0xLjQK")
        #   # => nil
        #
        def extract_mime_type(value)
          match = value.match(DocumentConstants::DATA_URI_REGEX)
          match ? match[1] : nil
        end

        # Validates complete filename format requirements
        #
        # Performs comprehensive filename validation including basic checks
        # and extension validation. Short-circuits on basic validation failures.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] filename to validate
        #
        # @example Valid filename
        #   validate_filename_format(key, "document.pdf")
        #   # No failure added
        #
        # @example Invalid filename
        #   validate_filename_format(key, "file<invalid>.exe")
        #   # Adds appropriate failure message
        #
        def validate_filename_format(key, value)
          return validate_filename_basic(key, value) unless filename_basic_valid?(value)

          validate_filename_extension(key, value)
        end

        # Checks if filename passes basic validation requirements
        #
        # Verifies filename is not empty, within length limits, and contains no invalid characters.
        #
        # @param value [String] filename to check
        # @return [Boolean] true if basic validation passes
        #
        # @example Valid basic filename
        #   filename_basic_valid?("document.pdf")
        #   # => true
        #
        # @example Invalid basic filename
        #   filename_basic_valid?("file<invalid>.pdf")
        #   # => false
        #
        def filename_basic_valid?(value)
          !value.strip.empty? &&
            value.length <= DocumentConstants::MAX_FILENAME_LENGTH &&
            !value.match?(DocumentConstants::INVALID_FILENAME_CHARS_REGEX)
        end

        # Validates basic filename requirements
        #
        # Checks for empty filename, length limits, and invalid characters.
        # Adds specific failure messages for each validation error.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] filename to validate
        #
        # @example Empty filename
        #   validate_filename_basic(key, "  ")
        #   # Adds failure: "cannot be empty"
        #
        # @example Too long filename
        #   validate_filename_basic(key, "A" * 300)
        #   # Adds failure: "maximum 255 characters"
        #
        # @example Invalid characters
        #   validate_filename_basic(key, "file<invalid>.pdf")
        #   # Adds failure: "contains invalid characters"
        #
        def validate_filename_basic(key, value)
          if value.strip.empty?
            key.failure(DocumentConstants::EMPTY_FILENAME_MESSAGE)
          elsif value.length > DocumentConstants::MAX_FILENAME_LENGTH
            key.failure(DocumentConstants::MAX_FILENAME_MESSAGE)
          elsif value.match?(DocumentConstants::INVALID_FILENAME_CHARS_REGEX)
            key.failure(DocumentConstants::INVALID_CHARS_MESSAGE)
          end
        end

        # Validates filename extension requirements
        #
        # Ensures filename has a valid file extension from supported formats.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] filename to validate
        #
        # @example Valid extension
        #   validate_filename_extension(key, "document.pdf")
        #   # No failure added
        #
        # @example No extension
        #   validate_filename_extension(key, "document")
        #   # Adds failure: "must have file extension"
        #
        # @example Invalid extension
        #   validate_filename_extension(key, "document.exe")
        #   # Adds failure: "extension must be: pdf, doc, docx, txt, jpg, jpeg, png"
        #
        def validate_filename_extension(key, value)
          extension = File.extname(value).downcase.gsub(".", "")

          if extension.empty?
            key.failure(DocumentConstants::NO_EXTENSION_MESSAGE)
          elsif !DocumentConstants::VALID_FORMATS_SET.include?(extension)
            key.failure(DocumentConstants::INVALID_EXTENSION_MESSAGE)
          end
        end

        # Validates base64 content requirements
        #
        # Validates base64 format, file size limits, and optionally checks
        # MIME type consistency with filename extension.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] base64 content to validate
        # @param filename [String, nil] optional filename for MIME type checking
        #
        # @example Valid base64 content
        #   validate_base64_content(key, "data:application/pdf;base64,JVBERi0xLjQK", "doc.pdf")
        #   # No failure added (assuming valid size and MIME match)
        #
        # @example Invalid base64
        #   validate_base64_content(key, "invalid_base64!")
        #   # Adds failure: "invalid Base64"
        #
        def validate_base64_content(key, value, filename = nil)
          begin
            decoded = Base64.strict_decode64(extract_base64_content(value))
          rescue ArgumentError
            key.failure(DocumentConstants::INVALID_BASE64_MESSAGE)
            return
          end

          validate_file_size(key, decoded)
          validate_mime_type_consistency(key, value, filename) if filename
        end

        # Validates file size limits
        #
        # Ensures decoded file size is within minimum and maximum limits.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param decoded [String] decoded file content
        #
        # @example Valid file size
        #   validate_file_size(key, "A" * 10000) # 10KB file
        #   # No failure added
        #
        # @example Too small file
        #   validate_file_size(key, "ABC") # 3 bytes
        #   # Adds failure: "file too small, minimum 1KB"
        #
        # @example Too large file
        #   validate_file_size(key, "A" * (30 * 1024 * 1024)) # 30MB
        #   # Adds failure: "file too large, maximum 25MB"
        #
        def validate_file_size(key, decoded)
          if decoded.size < DocumentConstants::MIN_FILE_SIZE
            key.failure(DocumentConstants::FILE_TOO_SMALL_MESSAGE)
          elsif decoded.size > DocumentConstants::MAX_FILE_SIZE
            key.failure(DocumentConstants::FILE_TOO_LARGE_MESSAGE)
          end
        end

        # Validates MIME type consistency with filename extension
        #
        # Ensures MIME type in data URI matches expected MIME type for file extension.
        #
        # @param key [Dry::Validation::Key] validation key for error reporting
        # @param value [String] base64 content with data URI
        # @param filename [String] filename with extension
        #
        # @example Consistent MIME type
        #   validate_mime_type_consistency(key, "data:application/pdf;base64,ABC", "doc.pdf")
        #   # No failure added
        #
        # @example Inconsistent MIME type
        #   validate_mime_type_consistency(key, "data:image/jpeg;base64,ABC", "doc.pdf")
        #   # Adds failure: "MIME type does not match extension"
        #
        def validate_mime_type_consistency(key, value, filename)
          mime_type = extract_mime_type(value)
          return unless mime_type

          expected_extension = File.extname(filename).downcase.gsub(".", "")
          expected_mime = DocumentConstants::VALID_MIME_TYPES[expected_extension]

          return unless expected_mime && mime_type != expected_mime

          key.failure(DocumentConstants::MIME_MISMATCH_MESSAGE)
        end
      end
    end
  end
end
