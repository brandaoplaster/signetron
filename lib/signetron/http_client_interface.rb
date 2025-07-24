# frozen_string_literal: true

module Signetron
  # Abstract interface for HTTP clients
  #
  # @abstract Subclasses must implement the {#request} method
  #
  # @example Implementing an HTTP client
  #   class MyHttpClient < Signetron::HttpClientInterface
  #     def request(method, url, payload = {}, headers = {})
  #       # your implementation here
  #     end
  #   end
  class HttpClientInterface
    # Executes an HTTP request
    #
    # @param method [Symbol, String] the HTTP method (:get, :post, :put, :delete, etc.)
    # @param url [String] the complete URL for the request
    # @param payload [Hash] the data to be sent in the request body (optional)
    # @param headers [Hash] additional HTTP headers (optional)
    #
    # @return [Object] request response (format varies by implementation)
    # @raise [NotImplementedError] if method is not implemented by subclass
    #
    # @example Usage (must be implemented by subclass)
    #   client.request(:get, 'https://api.example.com/users')
    #   client.request(:post, 'https://api.example.com/users', { name: 'John' })
    def request(method, url, payload = {}, headers = {})
      raise NotImplementedError, "Subclasses must implement request method"
    end
  end
end
