module Grape
  module JSONAPI
    class Streamer
      def initialize(collection)
        @collection = collection
      end

      def collection
        @collection
      end

      def first
        @first ||= true
      end

      def first=(first)
        @first = first
      end

      def each
        yield '{"data":['
        collection.lazy.each do |object|
          buffer = ''
          buffer << ',' unless first
          first = false
          data = serialize(object).as_json
          buffer << JSON.unparse(data)[8..-2].strip
          yield buffer
        end
        yield ']}'
      end

      def serialize(model)
        JSONAPI::Serializer.serialize(model, is_collection: false)
      end
    end
  end
end
