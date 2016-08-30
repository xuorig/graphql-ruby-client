module GraphQL
  module DocumentBuilder
    def self.build_query_from_selections(selections, variables: {})
      document = Language::Nodes::Document.new
      operation_definition = Language::Nodes::OperationDefinition.new(
        operation_type: 'query',
        variables: variables,
        selections: selections
      )

      document.definitions << operation_definition
      document
    end
  end
end
