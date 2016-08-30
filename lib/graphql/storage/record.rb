module GraphQL
  module Storage
    class Record
      attr_reader(:value)

      def initialize(value)
        @value = value
      end

      def id?
        @value.is_a?(Hash) && @value[:type] == 'id'
      end
    end
  end
end
