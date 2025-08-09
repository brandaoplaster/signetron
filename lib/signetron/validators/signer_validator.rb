# frozen_string_literal: true

require "dry-validation"
require_relative "constants/signer_constants"
require_relative "communicate_events_validator"
require_relative "helpers/signer_helpers"

module Signetron
  module Validators
    # Signer validation contract for signature participants
    #
    # Validates signer registration and update parameters including personal
    # information, contact details, documentation requirements, and communication
    # preferences. Ensures all signer data meets business rules and legal requirements.
    #
    # @example Valid signer data
    #   validator = SignerValidator.new
    #   result = validator.call(
    #     name: "João Silva Santos",
    #     email: "joao@example.com",
    #     phone_number: "+55 11 99999-9999",
    #     has_documentation: true,
    #     documentation: "123.456.789-00",
    #     birthday: Date.new(1990, 5, 15),
    #     communicate_events: {
    #       "signature_request" => "email",
    #       "signature_reminder" => "email",
    #       "document_signed" => "email"
    #     }
    #   )
    #   result.success? # => true
    #
    # @example Invalid signer data
    #   result = validator.call(
    #     name: "João123", # contains numbers
    #     email: "invalid-email",
    #     phone_number: "123",
    #     documentation: "invalid-cpf",
    #     birthday: Date.today - 10.years, # too young
    #     has_documentation: false,
    #     documentation: "123.456.789-00" # conflict with has_documentation
    #   )
    #   result.success? # => false
    #   result.errors.to_h # => detailed validation errors
    #
    class SignerValidator < Dry::Validation::Contract
      include Signetron::Validators::Helpers::SignerHelpers
      SignerConstants = Signetron::Validators::Constants::SignerConstants

      # Parameter schema definition
      #
      # Defines required and optional parameters with their types.
      # Only name is required, all other fields are optional for flexibility.
      params do
        required(:name).filled(:string)
        optional(:email).maybe(:string)
        optional(:phone_number).maybe(:string)
        optional(:has_documentation).maybe(:bool)
        optional(:documentation).maybe(:string)
        optional(:birthday).maybe(:date)
        optional(:refusable).maybe(:bool)
        optional(:group).maybe(:integer)
        optional(:location_required_enabled).maybe(:bool)
        optional(:communicate_events).maybe(:hash)
      end

      # Validates signer name requirements
      #
      # Ensures name meets length, format and content requirements.
      # Name must contain first and last name without numbers.
      rule(:name) do
        validate_name_length(key, value)
        validate_name_format(key, value)
        validate_name_no_numbers(key, value)
      end

      # Validates email address when provided
      #
      # Checks email format and length when email is present.
      rule(:email) do
        if value
          validate_email_format(key, value)
          validate_email_length(key, value)
        end
      end

      # Validates phone number format when provided
      #
      # Ensures phone number matches valid pattern when present.
      rule(:phone_number) do
        validate_phone_format(key, value) if value
      end

      # Validates CPF documentation format when provided
      #
      # Ensures CPF follows Brazilian format xxx.xxx.xxx-xx when present.
      rule(:documentation) do
        validate_documentation_format(key, value) if value
      end

      # Validates signer age based on birth date
      #
      # Ensures signer is of legal age when birthday is provided.
      rule(:birthday) do
        validate_birthday_age(key, value) if value
      end

      # Validates group number is positive
      #
      # Ensures group value is a positive integer when provided.
      rule(:group) do
        validate_positive_integer(key, value)
      end

      # Validates communication events configuration
      #
      # Delegates to CommunicateEventsValidator for detailed validation
      # of communication preferences structure and values.
      rule(:communicate_events) do
        if value
          events_result = Validators::CommunicateEventsValidator.new.call(value)
          unless events_result.success?
            events_result.errors.each do |error|
              key.failure("communicate_events.#{error.path.join('.')}: #{error.text}")
            end
          end
        end
      end

      # Validates documentation dependency rules
      #
      # Ensures documentation and birthday are not provided when
      # has_documentation is explicitly set to false.
      rule(:has_documentation, :documentation, :birthday) do
        if values[:has_documentation] == false
          key(:documentation).failure(SignerConstants::DOCUMENTATION_DEPENDENCY_MESSAGE) if values[:documentation]
          key(:birthday).failure(SignerConstants::DOCUMENTATION_DEPENDENCY_MESSAGE) if values[:birthday]
        end
      end

      # Validates email requirement based on communication events
      #
      # Ensures email is provided when communication events require email notifications.
      rule(:email, :communicate_events) do
        if values[:communicate_events]
          events_validator = Validators::CommunicateEventsValidator.new
          events_result = events_validator.call(values[:communicate_events])
          if events_result.success? && needs_email?(values[:communicate_events]) && !values[:email]
            key(:email).failure(SignerConstants::EMAIL_REQUIRED_MESSAGE)
          end
        end
      end

      # Validates phone requirement based on communication events
      #
      # Ensures phone number is provided when communication events require SMS or WhatsApp.
      rule(:phone_number, :communicate_events) do
        if values[:communicate_events]
          events_validator = Validators::CommunicateEventsValidator.new
          events_result = events_validator.call(values[:communicate_events])
          if events_result.success? && needs_phone?(values[:communicate_events]) && !values[:phone_number]
            key(:phone_number).failure(SignerConstants::PHONE_REQUIRED_MESSAGE)
          end
        end
      end
    end
  end
end
