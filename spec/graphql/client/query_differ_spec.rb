require "spec_helper"

describe GraphQL::Client::QueryDiffer do
  describe '#diff' do
    context 'when the store is empty' do
      let(:query) do
        GraphQL.parse(
          <<-GRAPHQL
            query trivialQuery {
              id
              stringField
              numberField
            }
          GRAPHQL
        )
      end

      let(:differ) do
        GraphQL::Client::QueryDiffer.new(
          query.definitions[0],
          GraphQL::Storage::NormalizedStore.new
        )
      end

      it 'returns all selections' do
        expect(differ.diff.missing_selections).to eql(query.definitions[0].selections)
      end
    end

    context 'when the store contains a field' do
      let(:query) do
        GraphQL.parse(
          <<-GRAPHQL
            query trivialQuery {
              id
              stringField
              numberField
            }
          GRAPHQL
        )
      end

      let(:store) do
        GraphQL::Storage::NormalizedStore.new(initial_state: {
          'ROOT' => {
            'stringField' => GraphQL::Storage::ScalarRecord.new('string value')
          }
        })
      end

      let(:differ) do
        GraphQL::Client::QueryDiffer.new(
          query.definitions[0],
          store
        )
      end

      it 'returns only the missing selections' do
        selections = query.definitions[0].selections
        expected = selections.reject { |selection| selection.name == 'stringField' }
        expect(differ.diff.missing_selections).to eql(expected)
      end
    end
  end
end
