# frozen_string_literal: true

module Signetron
  module Models
    class Envelope < Base
      def name
        @attributes[:name]
      end

      def locale
        @attributes[:locale]
      end

      def sequence_enabled
        @attributes[:sequence_enabled]
      end

      def auto_close
        @attributes[:auto_close]
      end

      def block_after_refusal
        @attributes[:block_after_refusal]
      end

      def deadline_at
        @attributes[:deadline_at]
      end

      def remind_interval
        @attributes[:remind_interval]
      end

      def external_id
        @attributes[:external_id]
      end

      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "envelopes",
            attributes: filter_nil_values(@attributes),
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
        @validator ||= Validators::EnvelopeValidator.new
      end

      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
