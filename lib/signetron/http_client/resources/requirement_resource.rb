# frozen_string_literal: true

module Signetron
  module HttpClient
    module Resources
      # Requirement resource for API interactions
      #
      # Handles requirement operations for qualification and authentication
      #
      # @example Creating a qualification requirement
      #   resource = Signetron::HttpClient::Resources::RequirementResource.new
      #   response = resource.qualification_requirement('env_123', {
      #     data: {
      #       type: "requirements",
      #       attributes: { action: "agree" },
      #       relationships: {
      #         document: { data: { type: "documents" } },
      #         signer: { data: { type: "signers" } }
      #       }
      #     }
      #   })
      #
      # @example Creating an authentication requirement
      #   response = resource.authentication_requirement('env_123', {
      #     data: {
      #       type: "requirements",
      #       attributes: { action: "provide_evidence" },
      #       relationships: {
      #         document: { data: { type: "documents" } },
      #         signer: { data: { type: "signers" } }
      #       }
      #     }
      #   })
      #
      # @example Getting a requirement
      #   response = resource.show('env_123', 'req_456')
      #
      # @example Deleting a requirement
      #   response = resource.delete('env_123', 'req_456')
      class RequirementResource < Signetron::Base
        class << self
          # Creates a qualification requirement for an envelope
          #
          # @param envelope_id [String] the envelope identifier
          # @param payload [Hash] the qualification requirement data in JSON API format
          # @option payload [Hash] :data the main data object
          # @option payload [String] :data.type the resource type ("requirements")
          # @option payload [Hash] :data.attributes the requirement attributes
          # @option payload [String] :data.attributes.action the action type ("agree")
          # @option payload [Hash] :data.relationships the related resources
          # @option payload [Hash] :data.relationships.document the document relationship
          # @option payload [Hash] :data.relationships.signer the signer relationship
          #
          # @return [Hash] the created qualification requirement
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   RequirementResource.qualification_requirement("env_123", {
          #     data: {
          #       type: "requirements",
          #       attributes: {
          #         action: "agree"
          #       },
          #       relationships: {
          #         document: {
          #           data: {
          #             type: "documents"
          #           }
          #         },
          #         signer: {
          #           data: {
          #             type: "signers"
          #           }
          #         }
          #       }
          #     }
          #   })
          def qualification_requirement(envelope_id, payload)
            request(:post, api_url("envelopes", envelope_id, "requirements"), payload)
          end

          # Creates an authentication requirement for an envelope
          #
          # @param envelope_id [String] the envelope identifier
          # @param payload [Hash] the authentication requirement data in JSON API format
          # @option payload [Hash] :data the main data object
          # @option payload [String] :data.type the resource type ("requirements")
          # @option payload [Hash] :data.attributes the requirement attributes
          # @option payload [String] :data.attributes.action the action type ("provide_evidence")
          # @option payload [Hash] :data.relationships the related resources
          # @option payload [Hash] :data.relationships.document the document relationship
          # @option payload [Hash] :data.relationships.signer the signer relationship
          #
          # @return [Hash] the created authentication requirement
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   RequirementResource.authentication_requirement("env_123", {
          #     data: {
          #       type: "requirements",
          #       attributes: {
          #         action: "provide_evidence"
          #       },
          #       relationships: {
          #         document: {
          #           data: {
          #             type: "documents"
          #           }
          #         },
          #         signer: {
          #           data: {
          #             type: "signers"
          #           }
          #         }
          #       }
          #     }
          #   })
          def authentication_requirement(envelope_id, payload)
            request(:post, api_url("envelopes", envelope_id, "requirements"), payload)
          end

          # Retrieves a requirement by ID
          #
          # @param envelope_id [String] the envelope identifier
          # @param requirement_id [String] the requirement identifier
          #
          # @return [Hash] the requirement data
          # @raise [RestClient::ResourceNotFound] if requirement not found
          #
          # @example
          #   RequirementResource.show("env_123", "req_456")
          def show(envelope_id, requirement_id)
            request(:get, api_url("envelopes", envelope_id, "requirements", requirement_id))
          end

          # Deletes a requirement
          #
          # @param envelope_id [String] the envelope identifier
          # @param requirement_id [String] the requirement identifier
          #
          # @return [Hash] deletion confirmation or empty response
          # @raise [RestClient::ResourceNotFound] if requirement not found
          #
          # @example
          #   RequirementResource.delete("env_123", "req_456")
          def delete(envelope_id, requirement_id)
            request(:delete, api_url("envelopes", envelope_id, "requirements", requirement_id))
          end
        end
      end
    end
  end
end
