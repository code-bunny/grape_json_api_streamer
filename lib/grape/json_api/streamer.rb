require 'jsonapi-serializers'

module Grape
  module JSONAPI
    class Streamer
      def initialize(collection, options = {})
        @collection = collection
        @options    = ActiveSupport::HashWithIndifferentAccess.new(options)
      end

      def each
        yield '{'
        yield "\"meta\": #{JSON.unparse(@options[:meta])}," if @options[:meta]
        yield '"data":['
        first = true
        @collection.lazy.each do |object|
          buffer = ''
          buffer << ',' unless first
          first = false
          data = serialize(object)
          buffer << JSON.unparse(data)[8..-2].strip
          yield buffer
        end
        yield ']'
        yield ",\"links\": #{JSON.unparse(@options[:links])}" if @options[:links]
        yield '}'
      end

      def serialize(model)
        ::JSONAPI::Serializer.serialize(model, is_collection: false)
      end
    end
  end
end
