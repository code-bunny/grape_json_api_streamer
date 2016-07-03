require 'jsonapi-serializers'

module Grape
  module JSONAPI
    class Streamer
      def initialize(collection)
        @collection = collection
      end

      def each
        yield '{"data":['
        first = true
        @collection.lazy.each do |object|
          buffer = ''
          buffer << ',' unless first
          first = false
          data = serialize(object)
          buffer << JSON.unparse(data)[8..-2].strip
          yield buffer
        end
        yield ']}'
      end

      def serialize(model)
        ::JSONAPI::Serializer.serialize(model, is_collection: false)
      end
    end
  end
end
