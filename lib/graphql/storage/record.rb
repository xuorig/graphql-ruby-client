module GraphQL
  module Storage
    class Record
      attr_reader(:value)

      def initialize(value)
        @value = value
      end
    end

    class ScalarRecord < Record
    end

    class ListRecord < Record
    end

    class IdRecord < Record
      attr_reader(:id, :generated)

      def initialize(id, generated: true)
        @id = id
        @generated = generated
      end
    end
  end
end
