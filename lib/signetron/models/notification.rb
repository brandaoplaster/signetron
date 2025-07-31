# frozen_string_literal: true

module Signetron
  module Models
    class Notification < Base
      def message
        @attributes[:message]
      end

      def to_json_api
        raise ValidationError.new(format_error_messages, @errors) unless valid?

        {
          data: {
            type: "notifications",
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
        @validator ||= Validators::NotificationValidator.new
      end

      def filter_nil_values(hash)
        hash.compact
      end
    end
  end
end
