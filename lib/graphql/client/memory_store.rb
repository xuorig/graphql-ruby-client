module GraphQL
  class Client
    class MemoryStore
      def initialize(initial_state: {})
        @store = initial_state
      end

      def read(key)
        @store[key]
      end

      def write(key, value)
        @store[key] = value
      end
    end
  end
end
