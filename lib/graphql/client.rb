require 'graphql'

require 'graphql/storage/helpers'
require 'graphql/storage/record'
require 'graphql/storage/memory_store'
require 'graphql/storage/normalized_store'

require 'graphql/client/version'
require 'graphql/client/request'
require 'graphql/client/query_differ'
require 'graphql/client/http_network_interface'

require 'graphql/document_builder'

module GraphQL
  class Client
    def initialize(network_interface: HTTPNetworkInterface.new('/graphql'))
      @network_interface = network_interface
      @store = GraphQL::Storage::NormalizedStore.new
    end

    def query(query_string, variables: {}, fragments: [], force_fetch: false)
      document = GraphQL.parse(query_string)
      minified_document = diff_query(document)

      puts "**** AFTER MINIFICATION ****"
      puts minified_document.to_query_string
      puts "**** AFTER MINIFICATION ****"

      graphql_request = Request.new(minified_document, variables)
      result = network_interface.query(graphql_request)

      write_result_to_store(minified_document, result)

      puts "**** NEW STORE STATE ****"
      puts store.inspect
      puts "**** NEW STORE STATE ****"

      result
    end

    private

    attr_reader(:network_interface, :store)

    def diff_query(query_document)
      diff = QueryDiffer.new(
        query_document.definitions[0],
        store
      ).diff

      result = diff.value
      missing_selections = diff.missing_selections

      GraphQL::DocumentBuilder.build_query_from_selections(missing_selections)
    end

    def write_result_to_store(document, result)
      query = document.definitions[0]
      store.write_query(query, result['data'])
    end
  end
end
