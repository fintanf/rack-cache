require 'set'
require 'rack/cache/headers'

module Rack::Cache
  # Provides access to the response generated by the downstream application. The
  # +response+, +original_response+, and +entry+ objects exposed by the Core
  # caching engine are instances of this class.
  #
  # Response objects respond to a variety of convenience methods, including
  # those defined in Rack::Response::Helpers, Rack::Cache::Headers,
  # and Rack::Cache::ResponseHeaders.
  #
  # Note that Rack::Cache::Response is not a subclass of Rack::Response and does
  # not perform many of the same initialization and finalization tasks. For
  # example, the body is not slurped during initialization and there are no
  # facilities for generating response output.

  class Response
    include Rack::Response::Helpers
    include Rack::Cache::Headers
    include Rack::Cache::ResponseHeaders

    # The response's status code (integer).
    attr_accessor :status

    # The response body. See the Rack spec for information on the behavior
    # required by this object.
    attr_accessor :body

    # The response headers.
    attr_reader :headers

    # Create a Response instance given the response status code, header hash,
    # and body.
    def initialize(status, headers, body)
      @status = status
      @headers = headers
      @body = body
      @now = Time.now
      @headers['Date'] ||= now.httpdate
    end

    def initialize_copy(other)
      super
      @headers = other.headers.dup
    end

    # Return the value of the named response header.
    def [](header_name)
      headers[header_name]
    end

    # Set a response header value.
    def []=(header_name, header_value)
      headers[header_name] = header_value
    end

    # Called immediately after an object is loaded from the cache.
    def activate!
      headers['Age'] = age.to_i.to_s
    end

    # Return the status, headers, and body in a three-tuple.
    def to_a
      [status, headers, body]
    end

    # Freezes
    def freeze
      @headers.freeze
      super
    end

  end

end
