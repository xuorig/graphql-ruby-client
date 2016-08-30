module GraphQL
  module Storage
    class NormalizedStore
      include Helpers

      ROOT_ID = 'ROOT'

      def initialize(initial_state: {})
        @store = initial_state
      end

      def [](key)
        store[key]
      end

      def write_query(query, result)
        write_selection_set(
          query.selections,
          data_id: ROOT_ID,
          result: result,
        )
      end

      def write_selection_set(selections, data_id:, result:)
        selections.each do |selection|
          case selection
          when Language::Nodes::Field
            resultKeyField = get_result_key_name(selection)
            value = result[resultKeyField]

            write_field(
              selection,
              data_id: data_id,
              value: value
            )
          else
            write_selection_set(
              selection.selections,
              data_id: data_id,
              result: result,
            )
          end
        end
      end

      def write_field(field, data_id:, value:)
        store_field_name = get_storage_key(field)

        if field.selections.empty? && !value.is_a?(Hash)
          store_value = Record.new(value)
        elsif value.is_a?(Array)
          ids = value.each_with_index.map do |item, index|
            item_data_id = "#{data_id}.#{store_field_name}.#{index}"

            write_selection_set(
              field.selections,
              data_id: item_data_id,
              result: item,
            )

            item_data_id
          end

          store_value = Record.new(ids)
        else
          value_data_id = "$#{data_id}.#{store_field_name}"

          write_selection_set(
            field.selections,
            data_id: value_data_id,
            result: value,
          )

          store_value = Record.new(
            type: 'id',
            id: value_data_id,
            generated: true
          )
        end

        current_value = store[data_id]

        new_value = (current_value || {}).merge(
          Hash[store_field_name, store_value]
        )

        if !current_value || store_value != current_value[store_field_name]
          store[data_id] = new_value
        end
      end

      private

      attr_reader(:store)
    end
  end
end
