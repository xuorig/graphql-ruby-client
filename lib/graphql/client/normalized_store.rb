require 'graphql/client/memory_store'

module GraphQL
  class Client
    class NormalizedStore
      def initialize(store: MemoryStore, initial_state: {})
        @store = store.new(initial_state)
      end

      def write_query(query, result)
        write_selection_set('ROOT', result, query.selections)
      end

      def read(key)
        store.read(key)
      end

      private

      attr_reader(:store)

      def write_selection_set(data_id, result, selection_set)
        selection_set.each do |selection|
          case selection
          when Language::Nodes::Field
            resultKeyField = get_field_result_key_name(selection)
            value = result[resultKeyField]
            write_field(data_id, selection, value)
          else
          end
        end
      end

      def write_field(data_id, field, value)
        store_field_name = get_store_field_name(field)

        if field.selections.empty? && !value.is_a?(Hash)
          store_value = value
        elsif value.is_a?(Array)
          store_value = value.each_with_index.map do |item, index|
            item_data_id = "#{data_id}.#{store_field_name}.#{index}"
            write_selection_set(item_data_id, item, field.selections)
            item_data_id
          end
        else
          value_data_id = "$#{data_id}.#{store_field_name}"
          write_selection_set(value_data_id, value, field.selections)

          store_value = {
            type: 'id',
            id: value_data_id,
            generated: true
          }
        end

        current_value = store.read(data_id)
        new_value = (current_value || {}).merge(Hash[store_field_name, store_value])

        if !current_value || store_value != current_value[store_field_name]
          store.write(data_id, new_value)
        end
      end

      def get_store_field_name(field)
        field.name
      end

      def get_field_result_key_name(selection)
        selection.alias || selection.name
      end
    end
  end
end
