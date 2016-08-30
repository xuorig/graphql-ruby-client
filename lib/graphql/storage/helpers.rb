module GraphQL
  module Storage
    module Helpers
      def get_storage_key(field, variables: {})
        field.name
      end

      def get_result_key_name(selection)
        selection.alias || selection.name
      end
    end
  end
end
