require 'jsonapi-serializers'

module Grape
  module JSONAPI
    class Streamer
      def initialize(collection, options = {})
        @collection = collection
        @options    = ActiveSupport::HashWithIndifferentAccess.new(options)
        @meta       = @options[:meta]
        @links      = @options[:links]
      end

      def each
        yield '{'
        yield "\"meta\": #{JSON.unparse(@meta)}," if @meta
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
        yield ",\"links\": #{JSON.unparse(@links)}" if @links
        yield '}'
      end

      def serialize(model)
        @options.delete(:meta)
        @options.delete(:links)
        @options[:is_collection] = false
        ::JSONAPI::Serializer.serialize(model, @options)
      end
    end
  end
end
