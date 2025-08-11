# frozen_string_literal: true

module Signetron
  # RestClient HTTP adapter implementation
  #
  # Implements HttpClientInterface using RestClient gem with Singleton pattern
  #
  # @example Basic usage
  #   adapter = Signetron::RestClientAdapter.instance
  #   response = adapter.request(:get, 'https://api.example.com/users')
  class RestClientAdapter < HttpClientInterface
    include Singleton

    # Executes an HTTP request using RestClient
    #
    # @param method [Symbol, String] the HTTP method (:get, :post, :put, :delete, etc.)
    # @param url [String] the complete URL for the request
    # @param payload [Hash] the data to be sent in the request body (optional)
    # @param headers [Hash] additional HTTP headers (optional)
    #
    # @return [RestClient::Response] the response object from RestClient
    # @raise [RestClient::ExceptionWithResponse] for HTTP error responses (4xx, 5xx)
    # @raise [RestClient::RequestTimeout] when request times out
    # @raise [RestClient::Unauthorized] for 401 responses
    # @raise [RestClient::Forbidden] for 403 responses
    # @raise [RestClient::ResourceNotFound] for 404 responses
    #
    # @example GET request
    #   adapter = RestClientAdapter.instance
    #   response = adapter.request(:get, 'https://api.example.com/users')
    #
    # @example POST with payload
    #   response = adapter.request(:post, 'https://api.example.com/users',
    #                             { name: 'John', email: 'john@example.com' })
    def request(method, url, payload = {}, headers = {})
      RestClient::Request.execute(
        method: method,
        url: url,
        payload: payload,
        headers: headers
      )
    end
  end
end
