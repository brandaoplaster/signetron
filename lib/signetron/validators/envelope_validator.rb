# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    class EnvelopeValidator < Dry::Validation::Contract
      VALID_LOCALES = %w[pt-BR en-US es-ES].freeze
      MIN_REMIND_INTERVAL = 1
      MAX_REMIND_INTERVAL = 30
      MAX_NAME_LENGTH = 255
      MAX_EXTERNAL_ID_LENGTH = 255

      params do
        required(:name).filled(:string)
        optional(:locale).maybe(:string)
        optional(:sequence_enabled).maybe(:bool)
        optional(:auto_close).maybe(:bool)
        optional(:block_after_refusal).maybe(:bool)
        optional(:deadline_at).maybe(:date_time)
        optional(:remind_interval).maybe(:integer)
        optional(:external_id).maybe(:string)
      end

      rule(:name) do
        if key? && value
          key.failure("deve ter pelo menos 1 caractere") if value.length < 1
          key.failure("deve ter no máximo #{MAX_NAME_LENGTH} caracteres") if value.length > MAX_NAME_LENGTH
        end
      end

      rule(:locale) do
        if key? && value && !VALID_LOCALES.include?(value)
          key.failure("deve ser um dos seguintes: #{VALID_LOCALES.join(', ')}")
        end
      end

      rule(:deadline_at) do
        key.failure("deve ser uma data futura") if key? && value && (value <= DateTime.now)
      end

      rule(:remind_interval) do
        if key? && value && !value.between?(MIN_REMIND_INTERVAL, MAX_REMIND_INTERVAL)
          key.failure("deve estar entre #{MIN_REMIND_INTERVAL} e #{MAX_REMIND_INTERVAL} dias")
        end
      end

      rule(:external_id) do
        if key? && value && (value.length > MAX_EXTERNAL_ID_LENGTH)
          key.failure("deve ter no máximo #{MAX_EXTERNAL_ID_LENGTH} caracteres")
        end
      end
    end
  end
end
