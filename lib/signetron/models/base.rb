# frozen_string_literal: true

module Signetron
  module Models
    class Base
      attr_reader :attributes, :errors

      def initialize(attributes = {})
        @attributes = {}
        @errors = []

        normalized_attrs = normalize_keys(attributes)

        result = validator.call(normalized_attrs)

        if result.success?
          @attributes = result.to_h
        else
          @errors = format_dry_errors(result.errors)
          raise ValidationError.new(format_error_messages, @errors)
        end
      end

      def valid?
        @errors.empty?
      end

      def invalid?
        !valid?
      end

      def to_h
        @attributes.dup
      end

      def errors_hash
        @errors.each_with_object({}) do |error, hash|
          field = error[:field]
          hash[field] ||= []
          hash[field] << error[:message]
        end
      end

      def update_attributes?(new_attributes)
        merged_attrs = @attributes.merge(normalize_keys(new_attributes))

        result = validator.call(merged_attrs)

        if result.success?
          @attributes = result.to_h
          @errors = []
          true
        else
          @errors = format_dry_errors(result.errors)
          false
        end
      end

      private

      def normalize_keys(attributes)
        case attributes
        when Hash
          attributes.transform_keys(&:to_sym)
        else
          {}
        end
      end

      def validator
        raise NotImplementedError, "Subclasses must implement #validator method"
      end

      def format_dry_errors(dry_errors)
        dry_errors.map do |error|
          {
            field: error.path.join(".").to_sym,
            message: error.text,
          }
        end
      end

      def format_error_messages
        @errors.map { |error| "#{error[:field]}: #{error[:message]}" }.join(", ")
      end
    end

    class ValidationError < StandardError
      attr_reader :errors

      def initialize(message, errors = [])
        super(message)
        @errors = errors
      end
    end
  end
end
