# frozen_string_literal: true

# Manages configuration settings for Signetron gem
module Signetron
  # @example
  #   config = Signetron::Configuration.new
  #   config.base_url = 'https://api.example.com'
  #   config.access_token = 'your_token'
  #   config.validate!
  class Configuration
    # @return [String] the base URL for API requests
    # @return [String] the API version (default: "v3")
    # @return [String] the access token for authentication
    # @return [Integer] request timeout in seconds (default: 30)
    attr_accessor :base_url, :api_version, :access_token, :timeout

    # Initialize configuration with default values
    #
    # @return [Configuration]
    def initialize
      @base_url = nil
      @api_version = "v3"
      @access_token = nil
      @timeout = 30
    end

    # Validates required configuration values
    #
    # @return [void]
    # @raise [ConfigurationError] if base_url or access_token is missing
    #
    # @example
    #   config.validate!  # raises error if invalid
    def validate!
      errors = []
      errors << "base_url is required" if base_url.nil? || base_url.empty?
      errors << "access_token is required" if access_token.nil? || access_token.empty?
      raise ConfigurationError, errors.join(", ") if errors.any?
    end

    # Set configuration for sandbox environment
    #
    # @return [String] the sandbox base URL
    #
    # @example
    #   config.sandbox_mode!
    def sandbox_mode!
      @base_url = "https://api.example.com"
    end

    # Set configuration for production environment
    #
    # @return [String] the production base URL
    #
    # @example
    #   config.production_mode!
    def production_mode!
      @base_url = "https://api.example.com"
    end
  end

  # Raised when configuration validation fails
  class ConfigurationError < StandardError; end

  class << self
    # Get global configuration instance
    #
    # @return [Configuration] the singleton configuration instance
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure Signetron with block
    #
    # @yield [Configuration] configuration instance
    # @return [Configuration] the configured instance
    # @raise [ConfigurationError] if validation fails
    #
    # @example
    #   Signetron.configure do |config|
    #     config.base_url = 'https://api.example.com'
    #     config.access_token = 'token123'
    #   end
    def configure
      yield(configuration) if block_given?
      configuration.validate!
      configuration
    end

    # Reset configuration to defaults
    #
    # @return [Configuration] new configuration instance
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Set global configuration to sandbox mode
    #
    # @return [String] the sandbox base URL
    def sandbox!
      configuration.sandbox_mode!
    end

    # Set global configuration to production mode
    #
    # @return [String] the production base URL
    def production!
      configuration.production_mode!
    end
  end
end
