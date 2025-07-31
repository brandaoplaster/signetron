# frozen_string_literal: true

require "dry-validation"

module Signetron
  module Validators
    class NotificationValidator < Dry::Validation::Contract
      params do
        optional(:message).maybe(:string)
      end

      rule(:message) do
        key.failure("must not be empty") if key? && value && value.strip.empty?
      end
    end
  end
end
