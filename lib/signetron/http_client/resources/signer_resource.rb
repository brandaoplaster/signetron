# frozen_string_literal: true

module Signetron
  module HttpClient
    module Resources
      # Signer resource for API interactions
      #
      # Handles all HTTP operations for signer endpoints including
      # creation, retrieval, listing, and deletion
      #
      # @example Creating a signer
      #   resource = Signetron::HttpClient::Resources::SignerResource.new
      #   response = resource.create('env_123', { name: 'John Doe', email: 'john@example.com' })
      #
      # @example Getting a signer
      #   response = resource.show('env_123', 'signer_id')
      #
      # @example Listing signers
      #   response = resource.list('envelope_id')
      #
      # @example Deleting a signer
      #   response = resource.delete('env_123', 'signer_id')
      class SignerResource < Signetron::Base
        class << self
          # Creates a new signer
          #
          # @param envelope_id [String] the parent envelope identifier
          # @param payload [Hash] the signer data
          # @option payload [String] :name the signer name
          # @option payload [String] :email the signer email
          # @option payload [String] :phone the signer phone number
          # @option payload [Integer] :order the signing order
          #
          # @return [Hash] the created signer data
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   SignerResource.create("env_123", {
          #     name: "John Doe",
          #     email: "john@example.com",
          #     phone: "+1234567890"
          #   })
          def create(envelope_id, payload)
            request(:post, api_url("envelopes", envelope_id, "signers"), payload)
          end

          # Retrieves a signer by ID
          #
          # @param envelope_id [String] the envelope identifier
          # @param signer_id [String] the signer identifier
          #
          # @return [Hash] the signer data
          # @raise [RestClient::ResourceNotFound] if signer not found
          #
          # @example
          #   SignerResource.show('env_123', 'signer_123')
          def show(envelope_id, signer_id)
            request(:get, api_url("envelopes", envelope_id, "signers", signer_id))
          end

          # Lists signers for a specific envelope
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [Hash] array of signers for the envelope
          #
          # @example List signers for envelope
          #   SignerResource.list('env_123')
          def list(envelope_id)
            request(:get, api_url("envelopes", envelope_id, "signers"))
          end

          # Filters signers for a specific envelope
          #
          # @param envelope_id [String] the envelope identifier
          # @param params [Hash] query parameters for filtering
          # @option params [String] :status filter by signer status
          # @option params [String] :search search in signer names
          #
          # @return [Hash] array of filtered signers for the envelope
          #
          # @example Filter signers by status
          #   SignerResource.filter('env_123', status: 'pending')
          #
          # @example Filter signers by name
          #   SignerResource.filter('env_123', search: 'john')
          def filter(envelope_id, params)
            url = "#{api_url('envelopes', envelope_id, 'signers')}?#{to_query_string(params)}"
            request(:get, url)
          end

          # Deletes a signer
          #
          # @param envelope_id [String] the envelope identifier
          # @param signer_id [String] the signer identifier
          #
          # @return [Hash] deletion confirmation or empty response
          # @raise [RestClient::ResourceNotFound] if signer not found
          #
          # @example
          #   SignerResource.delete('env_123', 'signer_123')
          def delete(envelope_id, signer_id)
            request(:delete, api_url("envelopes", envelope_id, "signers", signer_id))
          end

          private

          # Converts hash parameters to URL query string
          #
          # @param params [Hash] the parameters to convert
          # @return [String] URL-encoded query string
          def to_query_string(params)
            params.map { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join("&")
          end
        end
      end
    end
  end
end
