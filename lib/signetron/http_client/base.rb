# frozen_string_literal: true

module Signetron
  # Base class for API interactions
  #
  # Provides foundation for all API operations with HTTP client management,
  # request execution, URL building, and response parsing
  #
  # @example Basic usage
  #   Signetron.configure do |config|
  #     config.base_url = 'https://api.example.com'
  #     config.access_token = 'your_token'
  #   end
  #   response = Signetron::Base.request(:get, '/users')
  class Base
    class << self
      # Sets the HTTP client adapter to be used for requests
      #
      # @param adapter [HttpClientInterface] the HTTP client adapter instance
      # @return [HttpClientInterface] the assigned HTTP client adapter
      attr_writer :http_client

      # Gets the current HTTP client adapter instance
      #
      # @return [HttpClientInterface] the HTTP client adapter (defaults to RestClientAdapter)
      def http_client
        @http_client ||= Signetron::HttpClient::RestClientAdapter.instance
      end

      # Executes an HTTP request with automatic configuration validation
      #
      # @param method [Symbol, String] the HTTP method (:get, :post, :put, :delete, etc.)
      # @param url [String] the API endpoint URL
      # @param payload [Hash] the request payload/body data (optional)
      #
      # @return [Hash, Object] the parsed response data
      # @raise [ConfigurationError] if Signetron is not properly configured
      # @raise [RestClient::ExceptionWithResponse] for HTTP error responses
      #
      # @example GET request
      #   response = Signetron::Base.request(:get, '/users')
      #
      # @example POST request with payload
      #   response = Signetron::Base.request(:post, '/users', { name: 'John' })
      def request(method, url, payload = {})
        ensure_configured!

        # Use the adapter's request method instead of calling RestClient directly
        response = http_client.request(method, url, payload, add_headers)
        parse(response)
      end

      # Builds a complete API URL from path segments
      #
      # @param path [Array<String>] variable number of path segments
      #
      # @return [String] the complete API URL
      # @raise [ConfigurationError] if base_url or api_version are not configured
      #
      # @example Building a user endpoint
      #   url = Signetron::Base.api_url('users')
      #   # => "https://api.example.com/v1/users"
      #
      # @example Building nested resource endpoint
      #   url = Signetron::Base.api_url('users', '123', 'posts')
      #   # => "https://api.example.com/v1/users/123/posts"
      def api_url(*path)
        ensure_configured!
        ([base_url, api_version] + path).join("/")
      end

      # Parses the HTTP response from the adapter
      #
      # @param response [RestClient::Response, Object] the raw HTTP response from adapter
      #
      # @return [Hash, Object] the parsed response data (empty hash if response is empty)
      def parse(response)
        # Handle different response types depending on the adapter
        case response
        when RestClient::Response
          response.body.empty? ? {} : JSON.parse(response.body)
        else
          response.empty? ? {} : response
        end
      rescue JSON::ParserError
        # If JSON parsing fails, return the raw response
        response
      end

      # Sets a custom HTTP client adapter (useful for testing or different HTTP libraries)
      #
      # @param adapter_class [Class] the adapter class that implements HttpClientInterface
      #
      # @example Setting a custom adapter
      #   Signetron::Base.set_adapter(MyCustomAdapter)
      #
      # @example Setting adapter for testing
      #   Signetron::Base.set_adapter(MockHttpAdapter)
      def set_adapter(adapter_class)
        @http_client = adapter_class.instance
      end

      # Resets the HTTP client to default (RestClientAdapter)
      #
      # @return [void]
      def reset_adapter!
        @http_client = nil
      end

      private

      # Ensures that Signetron is properly configured before making requests
      #
      # @return [void]
      # @raise [ConfigurationError] if configuration validation fails
      def ensure_configured!
        config.validate!
      rescue ConfigurationError => e
        raise ConfigurationError, "Signetron not configured: #{e.message}. " \
                                  "Please add an initializer in config/initializers/signetron.rb"
      end

      # Gets the configured base URL
      #
      # @return [String] the base URL from configuration
      def base_url
        config.base_url
      end

      # Gets the configured API version
      #
      # @return [String] the API version from configuration
      def api_version
        config.api_version
      end

      # Gets the configured access token
      #
      # @return [String] the access token from configuration
      def access_token
        config.access_token
      end

      # Gets the current Signetron configuration
      #
      # @return [Configuration] the configuration instance
      def config
        Signetron.configuration
      end

      # Builds the standard headers for API requests
      #
      # @return [Hash] the headers hash with Content-Type, Accept, and Authorization
      def add_headers
        {
          "Content-Type" => "application/vnd.api+json",
          "Accept" => "application/vnd.api+json",
          "Authorization" => access_token.to_s,
        }
      end
    end
  end
end
