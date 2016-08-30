module GraphQL
  class Client
    class QueryDiffer
      class QueryDiffResult
        attr_reader(:value, :missing, :missing_selections)

        def initialize(result, missing: false, missing_selections: {})
          @result = result
          @missing = missing
          @missing_selections = missing_selections
        end
      end

      include GraphQL::Storage::Helpers

      def initialize(query, store)
        @query = query
        @store = store
      end

      def diff
        diff_selection_set(
          query.selections,
          root: Storage::NormalizedStore::ROOT_ID,
        )
      end

      def diff_selection_set(selections, root:)
        missing_selections = []
        result = {}

        selections.each do |selection|
          if selection.is_a?(Language::Nodes::Field)
            field_result = diff_field(selection, root: root)

            if field_result.missing
              missing_selections << selection
            else
              result[get_result_key_name(selection)] = field_result.value
            end
          else
            diff_result = diff_selection_set(
              selection.selections,
              root: root
            )

            if diff_result.missing
              missing_selections << selection
            else
              result.merge(diff_result.value)
            end
          end
        end

        missing = false

        if root != Storage::NormalizedStore::ROOT_ID
          missing = true unless missing_selections.empty?
        end

        QueryDiffResult.new(
          result,
          missing: missing,
          missing_selections: missing_selections,
        )
      end

      private

      attr_reader(:query, :store)

      def diff_field(field, root:)
        store_object = store[root] || {}
        storage_key = get_storage_key(field)
        record = store_object[storage_key]

        return QueryDiffResult.new(nil, missing: true) unless record

        case record
        when Storage::ScalarRecord
          QueryDiffResult.new(record.value)
        when Storage::ListRecord
          missing = false

          result = store_value.map do |item_id|
            return unless item

            item_diff_result = diff_selection_set(
              field.selections,
              root: item_id
            )

            missing = true unless item_diff_result.value
            item_diff_result.value
          end

          QueryDiffResult.new(
            result,
            missing: missing,
          )
        when Storage::IdRecord
          # Value is an id pointing to another object
          diff_selection_set(
            field.selections,
            root: record.id
          )
        else
          raise StandardError, 'Unexpected Record value in store'
        end
      end
    end
  end
end
