# frozen_string_literal: true

require "dry-validation"
require "singleton"

require_relative "signetron/version"
require_relative "signetron/http_client_interface"
require_relative "signetron/rest_client_adapter"
require_relative "signetron/models/base"
require_relative "signetron/models/envelope"
require_relative "signetron/models/document"
require_relative "signetron/models/signer"
require_relative "signetron/models/qualification"
require_relative "signetron/models/requirement"
require_relative "signetron/models/notification"
require_relative "signetron/validators/envelope_validator"
require_relative "signetron/validators/document_validator"
require_relative "signetron/validators/signer_validator"
require_relative "signetron/validators/qualification_validator"
require_relative "signetron/validators/requirement_validator"
require_relative "signetron/validators/notification_validator"

module Signetron
  class Error < StandardError; end
end
