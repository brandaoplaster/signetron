# frozen_string_literal: true

module Signetron
  module HttpClient
    class ErrorHandling < StandardError
      attr_reader :status_code, :response_body

      def initialize(status_code, response = nil)
        @status_code = status_code
        @response_body = extract_body(response)

        super(build_message)
      end

      private

      def extract_body(response)
        case response
        when String then response
        when nil then nil
        else
          response.respond_to?(:body) ? response.body : response.to_s
        end
      end

      def build_message
        api_message = extract_api_message
        api_message || "HTTP #{status_code} Error"
      end

      def extract_api_message
        return nil unless response_body

        parsed = JSON.parse(response_body)
        parsed["message"] || parsed["error"]
      rescue JSON::ParserError
        nil
      end
    end
  end
end
