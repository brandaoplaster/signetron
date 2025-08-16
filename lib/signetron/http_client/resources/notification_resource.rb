# frozen_string_literal: true

module Signetron
  module HttpClient
    module Resources
      # Notification resource for API interactions
      #
      # Handles notification operations for signers
      #
      # @example Notifying a specific signer
      #   resource = Signetron::HttpClient::Resources::NotificationResource.new
      #   response = resource.notify_signer('env_123', 'signer_456', { message: 'Please sign the document' })
      #
      # @example Notifying all signers in an envelope
      #   response = resource.notify_envelope_signers('env_123', { message: 'Documents ready for signing' })
      class NotificationResource < Signetron::Base
        class << self
          # Notifies a specific signer
          #
          # @param envelope_id [String] the envelope identifier
          # @param signer_id [String] the signer identifier
          # @param payload [Hash] the notification data
          # @option payload [String] :message the notification message
          #
          # @return [Hash] the notification response
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   NotificationResource.notify_signer("env_123", "signer_456", {
          #     message: "Please sign the document"
          #   })
          def notify_signer(envelope_id, signer_id, payload)
            request(:post, api_url("envelopes", envelope_id, "signers", signer_id, "notify"), payload)
          end

          # Notifies all signers in an envelope
          #
          # @param envelope_id [String] the envelope identifier
          # @param payload [Hash] the notification data
          # @option payload [String] :message the notification message
          #
          # @return [Hash] the notification response
          # @raise [RestClient::ExceptionWithResponse] for HTTP errors
          #
          # @example
          #   NotificationResource.notify_envelope_signers("env_123", {
          #     message: "Documents are ready for signing"
          #   })
          def notify_envelope_signers(envelope_id, payload)
            request(:post, api_url("envelopes", envelope_id, "notify"), payload)
          end
        end
      end
    end
  end
end
