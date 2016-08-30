require "spec_helper"

describe GraphQL::Storage::NormalizedStore do
  describe '#write_query' do
    before(:each) do
      @store = GraphQL::Storage::NormalizedStore.new
    end

    context 'when the result is a trivial object' do
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

      let(:result) do
        {
          'id' => '123',
          'stringField' => 'A string',
          'numberField' => 1,
        }
      end

      it 'normalizes the items' do
        @store.write_query(query.definitions[0], result)

        expect(@store['ROOT']['id'].value).to eq('123')
        expect(@store['ROOT']['stringField'].value).to eq('A string')
        expect(@store['ROOT']['numberField'].value).to eq(1)
      end
    end

    context 'when the result has nested objects' do
      let(:query) do
        GraphQL.parse(
          <<-GRAPHQL
            query trivialQuery {
              object {
                name
              }
            }
          GRAPHQL
        )
      end

      let(:result) do
        {
          'object' => {
            'name' => 'hello'
          }
        }
      end

      it 'normalizes the nested object' do
        @store.write_query(query.definitions[0], result)
        expect(@store['ROOT']['object'].value).to eq({
          type: 'id',
          id: '$ROOT.object',
          generated: true
        })
      end

      it 'writes the object to a new key' do
        @store.write_query(query.definitions[0], result)
        expect(@store['$ROOT.object']['name'].value).to eq('hello')
      end
    end

    context 'when the result has an array objects' do
      let(:query) do
        GraphQL.parse(
          <<-GRAPHQL
            query trivialQuery {
              objects {
                name
              }
            }
          GRAPHQL
        )
      end

      let(:result) do
        {
          'objects' => [{
            'name' => 'hello'
          }, {
            'name' => 'hello2'
          }]
        }
      end

      it 'normalizes the nested object' do
        @store.write_query(query.definitions[0], result)
        expect(@store['ROOT']['objects'].value).to eq(['ROOT.objects.0', 'ROOT.objects.1'])
      end

      it 'writes the objects to new keys' do
        @store.write_query(query.definitions[0], result)
        expect(@store['ROOT.objects.0']['name'].value).to eq('hello')
        expect(@store['ROOT.objects.1']['name'].value).to eq('hello2')
      end
    end

    context 'when the result contains inline fragments' do
      let(:query) do
        GraphQL.parse(
          <<-GRAPHQL
            query trivialQuery {
              ... on Object {
                name
                price
              }
            }
          GRAPHQL
        )
      end

      let(:result) do
        {
          'name' => 'hello',
          'price' => 2
        }
      end

      it 'normalizes the nested object' do
        @store.write_query(query.definitions[0], result)
        expect(@store['ROOT']['name'].value).to eq('hello')
        expect(@store['ROOT']['price'].value).to eq(2)
      end
    end
  end
end
