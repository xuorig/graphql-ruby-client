require "spec_helper"

describe GraphQL::Client::NormalizedStore do
  describe '#write_selection_set' do
    before(:each) do
      @store = GraphQL::Client::NormalizedStore.new
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
        @store.write_selection_set('ROOT', result, query.definitions[0].selections)
        expect(@store.read('ROOT')).to eq({
          'id' => '123',
          'stringField' => 'A string',
          'numberField' => 1,
        })
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
        @store.write_selection_set('ROOT', result, query.definitions[0].selections)
        expect(@store.read('ROOT')).to eq({
          'object' => {
            type: 'id',
            id: '$ROOT.object',
            generated: true
          },
        })
      end

      it 'writes the object to a new key' do
        @store.write_selection_set('ROOT', result, query.definitions[0].selections)
        expect(@store.read('$ROOT.object')).to eq({
          'name' => 'hello'
        })
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
        @store.write_selection_set('ROOT', result, query.definitions[0].selections)
        expect(@store.read('ROOT')).to eq({
          'objects' => ['ROOT.objects.0', 'ROOT.objects.1'],
        })
      end

      it 'writes the objects to new keys' do
        @store.write_selection_set('ROOT', result, query.definitions[0].selections)
        expect(@store.read('ROOT.objects.0')).to eq({
          'name' => 'hello'
        })
        expect(@store.read('ROOT.objects.1')).to eq({
          'name' => 'hello2'
        })
      end
    end
  end
end
