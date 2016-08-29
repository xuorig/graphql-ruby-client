require 'net/http'

module GraphQL
  class Client
    class HTTPNetworkInterface
      NetworkError = Class.new(StandardError)

      def initialize(uri)
        @uri = URI(uri)
        @http = Net::HTTP.new(@uri.host, @uri.port)
      end

      def query(request)
        response = fetch_remote(request)
        raise Networkerror unless success?(response)

        result = JSON.parse(response.body)

        if !result['data'] && !result['errors']
          raise ServerError, "Server response was missing for query #{request.debug_name}"
        end

        result
      end

      private

      attr_reader(:http, :uri)

      def fetch_remote(gql_request)
        request = Net::HTTP::Post.new(uri.request_uri, {
          'Accept' => '*/*',
          'Content-Type' => 'application/json'
        })

        request.body = {
          query: gql_request.query.to_query_string,
          variables: gql_request.variables,
        }.to_json

        http.request(request)
      end

      def success?(response)
        code = response.code.to_i
        code >= 200 && code < 300
      end
    end
  end
end
