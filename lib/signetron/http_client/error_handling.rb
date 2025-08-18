# frozen_string_literal: true

module Signetron
  module HttpClient
    # Standard error class for all HTTP-related errors
    #
    # Provides unified error handling for HTTP requests across different adapters,
    # extracting meaningful error messages from API responses and normalizing
    # status codes for consistent error handling throughout the application
    #
    # @example Basic usage
    #   begin
    #     response = EnvelopeResource.create(payload)
    #   rescue Signetron::HttpClient::ErrorHandling => e
    #     puts "HTTP Error #{e.status_code}: #{e.message}"
    #     puts "Response body: #{e.response_body}"
    #   end
    #
    # @example Checking specific error types
    #   begin
    #     response = EnvelopeResource.get('invalid_id')
    #   rescue Signetron::HttpClient::ErrorHandling => e
    #     case e.status_code
    #     when 404
    #       puts "Resource not found"
    #     when 401
    #       puts "Authentication required"
    #     when 500..599
    #       puts "Server error occurred"
    #     end
    #   end
    class ErrorHandling < StandardError
      # @return [Integer, Symbol] HTTP status code or connection error type
      # @example
      #   error.status_code  #=> 404, 500, :timeout, :connection_error
      attr_reader :status_code

      # @return [String, nil] Raw response body from the API
      # @example
      #   error.response_body  #=> '{"message": "Resource not found"}'
      attr_reader :response_body

      # Creates a new ErrorHandling instance
      #
      # @param status_code [Integer, Symbol] HTTP status code or error type
      # @param response [RestClient::Response, String, nil] HTTP response object or error message
      #
      # @example With HTTP status code
      #   ErrorHandling.new(404, response_object)
      #
      # @example With connection error
      #   ErrorHandling.new(:timeout, "Request timed out")
      #
      # @example With string response
      #   ErrorHandling.new(500, "Internal server error")
      def initialize(status_code, response = nil)
        @status_code = status_code
        @response_body = extract_body(response)

        super(build_message)
      end

      private

      # Extracts response body from various response types
      #
      # @param response [RestClient::Response, String, nil] the response object
      # @return [String, nil] extracted response body
      def extract_body(response)
        case response
        when String then response
        when nil then nil
        else
          response.respond_to?(:body) ? response.body : response.to_s
        end
      end

      # Builds error message from API response or default message
      #
      # @return [String] formatted error message
      def build_message
        api_message = extract_api_message
        api_message || "HTTP #{status_code} Error"
      end

      # Extracts error message from JSON API response
      #
      # @return [String, nil] API error message or nil if not found
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
