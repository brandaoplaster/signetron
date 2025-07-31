# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    class SignerValidator < Dry::Validation::Contract
      VALID_AUTHS = %w[email sms selfie official_document facial_biometrics].freeze
      MAX_NAME_LENGTH = 255
      MAX_EMAIL_LENGTH = 255
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
      PHONE_REGEX = /\A[\d\s\-\(\)]{10,15}\z/
      DOCUMENTATION_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/

      params do
        required(:email).filled(:string)
        required(:name).filled(:string)
        optional(:phone_number).maybe(:string)
        optional(:documentation).maybe(:string)
        optional(:birthday).maybe(:date)
        optional(:auths).maybe(:array)
        optional(:has_documentation).maybe(:bool)
        optional(:selfie_enabled).maybe(:bool)
        optional(:handwritten_enabled).maybe(:bool)
        optional(:official_document_enabled).maybe(:bool)
        optional(:liveness_enabled).maybe(:bool)
        optional(:facial_biometrics_enabled).maybe(:bool)
      end

      rule(:email) do
        validate_email_format(value)
        validate_email_length(value)
      end

      rule(:name) do
        validate_name_length(value)
        validate_name_format(value)
      end

      rule(:phone_number) do
        validate_phone_format(value) if value
      end

      rule(:documentation) do
        validate_documentation_format(value) if value
      end

      rule(:birthday) do
        validate_birthday_age(value) if value
      end

      rule(:auths) do
        validate_auths_values(value) if value
      end

      private

      def validate_email_format(value)
        return if value.match?(EMAIL_REGEX)

        key.failure("formato de email inválido")
      end

      def validate_email_length(value)
        return unless value.length > MAX_EMAIL_LENGTH

        key.failure("máximo #{MAX_EMAIL_LENGTH} caracteres")
      end

      def validate_name_length(value)
        key.failure("não pode estar vazio") if value.strip.empty?
        key.failure("máximo #{MAX_NAME_LENGTH} caracteres") if value.length > MAX_NAME_LENGTH
      end

      def validate_name_format(value)
        return unless value.strip.split.length < 2

        key.failure("deve conter nome e sobrenome")
      end

      def validate_phone_format(value)
        return if value.match?(PHONE_REGEX)

        key.failure("formato de telefone inválido")
      end

      def validate_documentation_format(value)
        return if value.match?(DOCUMENTATION_REGEX)

        key.failure("CPF deve estar no formato xxx.xxx.xxx-xx")
      end

      def validate_birthday_age(value)
        today = Date.today
        age = today.year - value.year
        age -= 1 if today < value.next_year(age)

        if age < 18
          key.failure("signatário deve ser maior de idade")
        elsif age > 120
          key.failure("data de nascimento inválida")
        end
      end

      def validate_auths_values(value)
        return unless value.is_a?(Array)

        invalid_auths = value - VALID_AUTHS
        key.failure("métodos de autenticação inválidos: #{invalid_auths.join(', ')}") unless invalid_auths.empty?

        return unless value.empty?

        key.failure("deve conter pelo menos um método de autenticação")
      end
    end
  end
end
