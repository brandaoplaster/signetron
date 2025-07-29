require "dry-validation"
require "base64"

module Signetron
  module Validators
    class DocumentValidator < Dry::Validation::Contract
      # Constantes
      VALID_FORMATS = %w[pdf doc docx txt jpg jpeg png].freeze
      VALID_MIME_TYPES = {
        "pdf" => "application/pdf",
        "doc" => "application/msword",
        "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "txt" => "text/plain",
        "jpg" => "image/jpeg",
        "jpeg" => "image/jpeg",
        "png" => "image/png",
      }.freeze
      MAX_FILENAME_LENGTH = 255
      MAX_PATH_LENGTH = 500
      MAX_FILE_SIZE = 25 * 1024 * 1024
      MIN_FILE_SIZE = 1024

      params do
        required(:filename).filled(:string)
        required(:content_base64).filled(:string)
      end

      rule(:filename) do
        validate_filename_length(value)
        validate_filename_characters(value)
        validate_filename_extension(value)
      end

      rule(:content_base64) do
        validate_base64_format(value)
        validate_file_size(value)
        validate_mime_type(value, values[:filename])
      end

      private

      def validate_filename_length(value)
        key.failure("não pode estar vazio") if value.strip.empty?
        key.failure("máximo #{MAX_FILENAME_LENGTH} caracteres") if value.length > MAX_FILENAME_LENGTH
      end

      def validate_filename_characters(value)
        return unless value.match?(%r{[<>:"|?*\\/]})

        key.failure("contém caracteres inválidos")
      end

      def validate_filename_extension(value)
        extension = File.extname(value).downcase.gsub(".", "")
        if extension.empty?
          key.failure("deve ter extensão de arquivo")
        elsif !VALID_FORMATS.include?(extension)
          key.failure("extensão deve ser: #{VALID_FORMATS.join(', ')}")
        end
      end

      def validate_base64_format(value)
        Base64.strict_decode64(extract_base64_content(value))
      rescue ArgumentError
        key.failure("Base64 inválido")
      end

      def validate_file_size(value)
        decoded = Base64.strict_decode64(extract_base64_content(value))
        if decoded.size < MIN_FILE_SIZE
          key.failure("arquivo muito pequeno, mínimo #{MIN_FILE_SIZE / 1024}KB")
        elsif decoded.size > MAX_FILE_SIZE
          key.failure("arquivo muito grande, máximo #{MAX_FILE_SIZE / (1024 * 1024)}MB")
        end
      rescue ArgumentError
        # Erro já tratado em validate_base64_format
      end

      def validate_mime_type(value, filename)
        return unless filename

        mime_type = extract_mime_type(value)
        return unless mime_type

        expected_extension = File.extname(filename).downcase.gsub(".", "")
        expected_mime = VALID_MIME_TYPES[expected_extension]

        return unless expected_mime && mime_type != expected_mime

        key.failure("MIME type não confere com extensão")
      end

      def extract_base64_content(value)
        value.match(/^data:[^;]+;base64,(.+)$/) ? ::Regexp.last_match(1) : value
      end

      def extract_mime_type(value)
        value.match(/^data:([^;]+);base64,/) ? ::Regexp.last_match(1) : nil
      end
    end
  end
end
