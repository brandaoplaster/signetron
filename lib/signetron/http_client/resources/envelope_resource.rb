# frozen_string_literal: true

module Signetron
  module HttpClient
    module Resources
      # Envelope resource for API interactions
      #
      # Handles all HTTP operations for envelope endpoints including
      # creation, retrieval, updates, and deletion
      #
      # @example Creating an envelope
      #   resource = Signetron::HttpClient::Resources::EnvelopeResource.new
      #   response = resource.create({ title: 'Contract', locale: 'en-US', auto_close: false })
      #
      # @example Getting an envelope
      #   response = resource.get('envelope_id')
      #
      # @example Updating an envelope
      #   response = resource.update('envelope_id', { title: 'Updated Contract' })
      #
      # @example Deleting an envelope
      #   response = resource.delete('envelope_id')
      class EnvelopeResource < Signetron::Base
        class << self
          # Creates a new envelope
          #
          # @param payload [Hash] the envelope data
          # @option payload [String] :title the envelope title
          # @option payload [String] :description the envelope description
          # @option payload [Array<Hash>] :signers array of signer objects
          # @option payload [Array<Hash>] :documents array of document objects
          #
          # @return [Hash] the created envelope data
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   EnvelopeResource.create({
          #     name: "Contract Agreement",
          #     locale: "pt-BR",
          #     auto_close: false
          #   })
          def create(payload)
            request(:post, api_url("envelopes"), payload)
          end

          # Retrieves an envelope by ID
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [Hash] the envelope data
          # @raise [RestClient::ResourceNotFound] if envelope not found
          #
          # @example
          #   EnvelopeResource.get('envelope_123')
          def get(envelope_id)
            request(:get, api_url("envelopes", envelope_id))
          end

          # Updates an existing envelope
          #
          # @param envelope_id [String] the envelope identifier
          # @param payload [Hash] the data to update
          #
          # @return [Hash] the updated envelope data
          # @raise [RestClient::ResourceNotFound] if envelope not found
          #
          # @example
          #   EnvelopeResource.update('envelope_123', {
          #     title: 'Updated Contract Title'
          #   })
          def update(envelope_id, payload)
            request(:put, api_url("envelopes", envelope_id), payload)
          end

          # Deletes an envelope
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [Hash] deletion confirmation or empty response
          # @raise [RestClient::ResourceNotFound] if envelope not found
          #
          # @example
          #   EnvelopeResource.delete('envelope_123')
          def delete(envelope_id)
            request(:delete, api_url("envelopes", envelope_id))
          end

          # Lists all envelopes with optional filtering
          #
          # @param params [Hash] query parameters for filtering/pagination
          # @option params [Integer] :page page number for pagination
          # @option params [Integer] :per_page items per page
          # @option params [String] :status filter by envelope status
          # @option params [String] :search search term
          #
          # @return [Hash] array of envelopes and pagination metadata
          #
          # @example List with pagination
          #   EnvelopeResource.list(page: 1, per_page: 10)
          #
          # @example List with status filter
          #   EnvelopeResource.list(status: 'pending')
          def list(params = {})
            url = params.empty? ? api_url("envelopes") : "#{api_url('envelopes')}?#{to_query_string(params)}"
            request(:get, url)
          end

          # Sends an envelope for signing
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [Hash] response with send confirmation
          # @raise [RestClient::ResourceNotFound] if envelope not found
          # @raise [RestClient::UnprocessableEntity] if envelope cannot be sent
          #
          # @example
          #   EnvelopeResource.send_for_signing('envelope_123')
          def send_for_signing(envelope_id)
            request(:post, api_url("envelopes", envelope_id, "send"))
          end

          # Gets envelope status and signing progress
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [Hash] envelope status and signer progress
          #
          # @example
          #   EnvelopeResource.status('envelope_123')
          def status(envelope_id)
            request(:get, api_url("envelopes", envelope_id, "status"))
          end

          # Downloads the completed envelope as PDF
          #
          # @param envelope_id [String] the envelope identifier
          #
          # @return [String] PDF file content (binary)
          # @raise [RestClient::ResourceNotFound] if envelope not found
          # @raise [RestClient::UnprocessableEntity] if envelope not completed
          #
          # @example
          #   pdf_content = EnvelopeResource.download('envelope_123')
          #   File.write('contract.pdf', pdf_content)
          def download(envelope_id)
            request(:get, api_url("envelopes", envelope_id, "download"))
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
