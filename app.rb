# frozen_string_literal: true

require 'functions_framework'
require 'httparty'
require 'json'

# Entry point for Cloud Function
FunctionsFramework.http 'hello_xss' do |request|
  response = {
    message: 'XSS Scanner is ready!',
    timestamp: Time.now.iso8601,
    method: request.request_method
  }

  response.to_json
end
