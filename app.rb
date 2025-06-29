# frozen_string_literal: true

require 'functions_framework'
require 'httparty'
require 'json'
require 'uri'

# Entry point for Cloud Function
FunctionsFramework.http 'hello_xss' do |request|
  begin
    case request.request_method
    when 'GET'
      response = {
        message: 'XSS Scanner is ready!',
        timestamp: Time.now.iso8601,
        method: request.request_method,
        usage: 'POST with {"target_url": "https://example.com"} to scan'
      }
    when 'POST'
      # Parse request body
      body = JSON.parse(request.body.read)
      target_url = body['target_url']

      # Validation
      if target_url.nil? || target_url.empty?
        return {
          error: 'target_url is required',
          timestamp: Time.now.iso8601
        }.to_json
      else
        # URL format validation
        unless valid_url?(target_url)
          return {
            error: 'Invalid URL format',
            status: 400
          }.to_json
        end

        # Execute XSS scan
        scanner = BasicXSSScanner.new(target_url)
        scan_results = scanner.scan

        # Return results
        response = {
          target_url: target_url,
          timestamp: Time.now.iso8601,
          vulnerabilities_found: scan_results.length,
          results: scan_results
        }
      end
    else
      response = {
        error: 'Method not allowed',
        allowed_methods: %w[GET POST],
        timestamp: Time.now.iso8601
      }
    end
  rescue JSON::ParserError
    response = {
      error: 'Invalid JSON in request body',
      timestamp: Time.now.iso8601
    }
  rescue StandardError => e
    response = {
      error: "Internal error: #{e.message}",
      timestamp: Time.now.iso8601
    }
  end

  response.to_json
end

# URL validation helper
def valid_url?(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
rescue URI::InvalidURIError
  false
end

# Basic XSS scanner for testing web applications
# Performs simple payload injection tests via GET parameters
class BasicXSSScanner
  def initialize(target_url)
    @target_url = target_url
    @payloads = [
      '<script>alert("XSS")</script>',
      '"><script>alert("XSS")</script>',
      '<img src=x onerror=alert("XSS")>'
    ]
  end

  def scan
    puts "Scanning: #{@target_url}"
    results = []

    @payloads.each_with_index do |payload, index|
      puts "Testing payload #{index + 1}/#{@payloads.length}: #{payload[0..30]}..."

      result = test_payload(payload)
      results << result if result
    end

    results
  end

  private

  def test_payload(payload)
    # Test with GET parameter
    test_url = "#{@target_url}?test=#{URI.encode_www_form_component(payload)}"

    begin
      response = HTTParty.get(test_url, timeout: 10)

      if vulnerable?(response.body, payload)
        return {
          payload: payload,
          method: 'GET',
          parameter: 'test',
          url: test_url,
          vulnerable: true,
          response_length: response.body.length
        }
      end
    rescue StandardError => e
      return {
        payload: payload,
        method: 'GET',
        parameter: 'test',
        url: test_url,
        vulnerable: false,
        error: e.message
      }
    end

    nil
  end

  def vulnerable?(response_body, payload)
    # Simple detection: check if payload is directly included
    response_body.include?(payload)
  end
end
