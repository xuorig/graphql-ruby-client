module GraphQL
  module DocumentBuilder
    def self.build_query_from_selections(selection, variables: {})
      document = Language::Document.new
      operation_definition = Language::OperationDefinition.new(
        operation_type: 'query',
        variables: variables,
        selections: selections
      )

      document.definitions << operation_definition
      document
    end
  end
end
