# frozen_string_literal: true

module Signetron
  module Validators
    module Constants
      # Document validation constants
      #
      # Contains all validation constants for document uploads including
      # valid file formats, MIME type mappings, size limits, validation
      # patterns, and error messages for document data validation.
      #
      # @example Using validation constants
      #   # Check if file format is valid
      #   extension = "pdf"
      #   valid = DocumentConstants::VALID_FORMATS_SET.include?(extension)
      #
      #   # Get MIME type for extension
      #   mime_type = DocumentConstants::VALID_MIME_TYPES["pdf"]
      #   # => "application/pdf"
      #
      #   # Validate filename characters
      #   filename = "document<invalid>.pdf"
      #   has_invalid_chars = filename.match?(DocumentConstants::INVALID_FILENAME_CHARS_REGEX)
      #
      module DocumentConstants
        # Valid file extensions supported by the system
        VALID_FORMATS = %w[pdf doc docx txt jpg jpeg png].freeze

        # Set for fast validation lookup
        VALID_FORMATS_SET = VALID_FORMATS.to_set.freeze

        # MIME types mapping for file extensions
        VALID_MIME_TYPES = {
          "pdf" => "application/pdf",
          "doc" => "application/msword",
          "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          "txt" => "text/plain",
          "jpg" => "image/jpeg",
          "jpeg" => "image/jpeg",
          "png" => "image/png",
        }.freeze

        # Maximum filename length in characters
        MAX_FILENAME_LENGTH = 255

        # Maximum file path length in characters
        MAX_PATH_LENGTH = 500

        # Maximum file size in bytes (25MB)
        MAX_FILE_SIZE = 25 * 1024 * 1024

        # Minimum file size in bytes (1KB)
        MIN_FILE_SIZE = 1024

        # Regex pattern for invalid filename characters
        INVALID_FILENAME_CHARS_REGEX = %r{[<>:"|?*\\/]}

        # Regex pattern for data URI format validation
        DATA_URI_REGEX = /\Adata:([^;]+);base64,(.+)\z/

        # Error messages for filename validation
        EMPTY_FILENAME_MESSAGE = "cannot be empty"
        MAX_FILENAME_MESSAGE = "maximum #{MAX_FILENAME_LENGTH} characters".freeze
        INVALID_CHARS_MESSAGE = "contains invalid characters"
        NO_EXTENSION_MESSAGE = "must have file extension"
        INVALID_EXTENSION_MESSAGE = "extension must be: #{VALID_FORMATS.join(', ')}".freeze

        # Error messages for content validation
        INVALID_BASE64_MESSAGE = "invalid Base64"
        FILE_TOO_SMALL_MESSAGE = "file too small, minimum #{MIN_FILE_SIZE / 1024}KB".freeze
        FILE_TOO_LARGE_MESSAGE = "file too large, maximum #{MAX_FILE_SIZE / (1024 * 1024)}MB".freeze
        MIME_MISMATCH_MESSAGE = "MIME type does not match extension"
      end
    end
  end
end
