# frozen_string_literal: true

require "dry-validation"
require "base64"

module Signetron
  module Validators
    # Document validation contract for file uploads
    #
    # Validates document files including filename format, file extension,
    # base64 encoding, file size limits, and MIME type consistency.
    # Ensures uploaded documents meet security and format requirements.
    #
    # @example Valid document data
    #   validator = DocumentValidator.new
    #   result = validator.call(
    #     filename: "contract.pdf",
    #     content_base64: "data:application/pdf;base64,JVBERi0xLjQK..."
    #   )
    #   result.success? # => true
    #
    # @example Invalid document data
    #   result = validator.call(
    #     filename: "file.exe",
    #     content_base64: "invalid_base64"
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => { filename: ["extensão deve ser: pdf, doc, docx, txt, jpg, jpeg, png"],
    #                      #      content_base64: ["Base64 inválido"] }
    #
    class DocumentValidator < Dry::Validation::Contract
      # Valid file extensions supported by the system
      VALID_FORMATS = %w[pdf doc docx txt jpg jpeg png].freeze

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

      # Parameter schema definition
      #
      # Requires both filename and base64 content to be present and non-empty strings.
      params do
        required(:filename).filled(:string)
        required(:content_base64).filled(:string)
      end

      # Validates filename requirements
      #
      # Checks filename length, invalid characters, and required file extension.
      #
      # @example Valid filenames
      #   "document.pdf" # => valid
      #   "contract_v2.docx" # => valid
      #
      # @example Invalid filenames
      #   "" # => "não pode estar vazio"
      #   "file<invalid>.pdf" # => "contém caracteres inválidos"
      #   "document" # => "deve ter extensão de arquivo"
      #
      rule(:filename) do
        validate_filename_length(value)
        validate_filename_characters(value)
        validate_filename_extension(value)
      end

      # Validates base64 content requirements
      #
      # Checks base64 format validity, file size limits, and MIME type consistency.
      #
      # @example Valid base64 content
      #   "data:application/pdf;base64,JVBERi0xLjQK..." # => valid (with data URI)
      #   "JVBERi0xLjQK..." # => valid (raw base64)
      #
      # @example Invalid base64 content
      #   "invalid_base64!" # => "Base64 inválido"
      #   "data:application/pdf;base64,ABC" # => "arquivo muito pequeno, mínimo 1KB"
      #
      rule(:content_base64) do
        validate_base64_format(value)
        validate_file_size(value)
        validate_mime_type(value, values[:filename])
      end

      private

      # Validates filename length constraints
      #
      # @param value [String] filename to validate
      # @return [void]
      #
      # @example
      #   validate_filename_length("") # => adds "não pode estar vazio" error
      #   validate_filename_length("a" * 300) # => adds length limit error
      #
      def validate_filename_length(value)
        key.failure("cannot be empty") if value.strip.empty?
        key.failure("maximum #{MAX_FILENAME_LENGTH} characters") if value.length > MAX_FILENAME_LENGTH
      end

      # Validates filename contains no invalid characters
      #
      # @param value [String] filename to validate
      # @return [void]
      #
      # @example
      #   validate_filename_characters("file<test>.pdf") # => adds invalid characters error
      #   validate_filename_characters("normal_file.pdf") # => no error
      #
      def validate_filename_characters(value)
        return unless value.match?(%r{[<>:"|?*\\/]})

        key.failure("contains invalid characters")
      end

      # Validates filename has a supported extension
      #
      # @param value [String] filename to validate
      # @return [void]
      #
      # @example
      #   validate_filename_extension("file.exe") # => adds unsupported extension error
      #   validate_filename_extension("document") # => adds missing extension error
      #   validate_filename_extension("file.pdf") # => no error
      #
      def validate_filename_extension(value)
        extension = File.extname(value).downcase.gsub(".", "")

        if extension.empty?
          key.failure("must have file extension")
        elsif !VALID_FORMATS.include?(extension)
          key.failure("extension must be: #{VALID_FORMATS.join(', ')}")
        end
      end

      # Validates base64 encoding format
      #
      # @param value [String] base64 string to validate
      # @return [void]
      #
      # @example
      #   validate_base64_format("invalid!") # => adds Base64 error
      #   validate_base64_format("SGVsbG8=") # => no error
      #
      def validate_base64_format(value)
        Base64.strict_decode64(extract_base64_content(value))
      rescue ArgumentError
        key.failure("invalid Base64")
      end

      # Validates file size is within acceptable limits
      #
      # @param value [String] base64 string to validate
      # @return [void]
      #
      # @example
      #   validate_file_size("QQ==") # => adds file too small error
      #   validate_file_size(large_base64) # => adds file too large error
      #
      def validate_file_size(value)
        decoded = Base64.strict_decode64(extract_base64_content(value))

        if decoded.size < MIN_FILE_SIZE
          key.failure("file too small, minimum #{MIN_FILE_SIZE / 1024}KB")
        elsif decoded.size > MAX_FILE_SIZE
          key.failure("file too large, maximum #{MAX_FILE_SIZE / (1024 * 1024)}MB")
        end
      rescue ArgumentError
        # Error already handled in validate_base64_format
      end

      # Validates MIME type matches file extension
      #
      # @param value [String] base64 string with optional data URI
      # @param filename [String] filename with extension
      # @return [void]
      #
      # @example
      #   validate_mime_type("data:image/png;base64,ABC", "file.pdf") # => adds MIME type error
      #   validate_mime_type("data:application/pdf;base64,ABC", "file.pdf") # => no error
      #
      def validate_mime_type(value, filename)
        return unless filename

        mime_type = extract_mime_type(value)
        return unless mime_type

        expected_extension = File.extname(filename).downcase.gsub(".", "")
        expected_mime = VALID_MIME_TYPES[expected_extension]

        return unless expected_mime && mime_type != expected_mime

        key.failure("MIME type does not match extension")
      end

      # Extracts base64 content from data URI or returns as-is
      #
      # @param value [String] base64 string with optional data URI
      # @return [String] clean base64 content
      #
      # @example
      #   extract_base64_content("data:image/png;base64,SGVsbG8=") # => "SGVsbG8="
      #   extract_base64_content("SGVsbG8=") # => "SGVsbG8="
      #
      def extract_base64_content(value)
        value.match(/^data:[^;]+;base64,(.+)$/) ? ::Regexp.last_match(1) : value
      end

      # Extracts MIME type from data URI
      #
      # @param value [String] base64 string with optional data URI
      # @return [String, nil] MIME type or nil if not found
      #
      # @example
      #   extract_mime_type("data:application/pdf;base64,ABC") # => "application/pdf"
      #   extract_mime_type("SGVsbG8=") # => nil
      #
      def extract_mime_type(value)
        value.match(/^data:([^;]+);base64,/) ? ::Regexp.last_match(1) : nil
      end
    end
  end
end
