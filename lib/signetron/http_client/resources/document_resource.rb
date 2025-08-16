# frozen_string_literal: true

module Signetron
  module HttpClient
    module Resources
      # Document resource for API interactions
      #
      # Handles all HTTP operations for document endpoints including
      # creation, retrieval, updates, and deletion
      #
      # @example Creating a document
      #   resource = Signetron::HttpClient::Resources::DocumentResource.new
      #   response = resource.create({ envelope_id: 'env_123', title: 'Contract.pdf', content: 'base64...' })
      #
      # @example Getting a document
      #   response = resource.get('document_id')
      #
      # @example Updating a document
      #   response = resource.update('document_id', { title: 'Updated Contract.pdf' })
      #
      # @example Deleting a document
      #   response = resource.delete('document_id')
      class DocumentResource < Signetron::Base
        class << self
          # Creates a new document
          #
          # @param payload [Hash] the document data
          # @option payload [String] :envelope_id the parent envelope identifier
          # @option payload [String] :title the document title
          # @option payload [String] :content base64 encoded document content
          # @option payload [String] :content_type document MIME type
          #
          # @return [Hash] the created document data
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   DocumentResource.create({
          #     envelope_id: "env_123",
          #     title: "Service Agreement.pdf",
          #     content: "base64_encoded_content..."
          #   })
          def create(payload)
            request(:post, api_url("documents"), payload)
          end

          # Retrieves a document by ID
          #
          # @param document_id [String] the document identifier
          #
          # @return [Hash] the document data
          # @raise [RestClient::ResourceNotFound] if document not found
          #
          # @example
          #   DocumentResource.get('document_123')
          def get(document_id)
            request(:get, api_url("documents", document_id))
          end

          # Updates an existing document
          #
          # @param document_id [String] the document identifier
          # @param payload [Hash] the data to update
          #
          # @return [Hash] the updated document data
          # @raise [RestClient::ResourceNotFound] if document not found
          #
          # @example
          #   DocumentResource.update('document_123', {
          #     title: 'Updated Document Title.pdf'
          #   })
          def update(document_id, payload)
            request(:put, api_url("documents", document_id), payload)
          end

          # Deletes a document
          #
          # @param document_id [String] the document identifier
          #
          # @return [Hash] deletion confirmation or empty response
          # @raise [RestClient::ResourceNotFound] if document not found
          #
          # @example
          #   DocumentResource.delete('document_123')
          def delete(document_id)
            request(:delete, api_url("documents", document_id))
          end
        end
      end
    end
  end
end
