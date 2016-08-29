module GraphQL
  class Client
    class Request
      attr_reader(:query, :variables, :operation_name, :debug_name)

      def initialize(document, variables: {})
        @query = document
        @variables = variables
        @operation_name = document.definitions[0].operation_type
        @debug_name = document.definitions[0].name
      end
    end
  end
end
