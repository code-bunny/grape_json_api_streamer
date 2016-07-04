# grape_json_api_streamer

Based heavily on the suggestion by raulpopadineti at https://github.com/ruby-grape/grape/issues/1392 which is used for streaming Grape::Entity, this class provides a way to stream JSON::API using the jsonapi-serializers gem in grape.

## Example
```
require 'grape'
require 'grape/json_api/streamer'

class Model
  def initialize(id)
    @id = id
  end

  def id
    @id
  end

  def foo
    'bar'
  end
end

class ModelSerializer
  include JSONAPI::Serializer

  attribute :foo
end

class MockAPI < Grape::API
  format :json
  content_type :json, 'application/json;charset=UTF-8'

  resource :foo do
    get do
      model  = Model.new(1)
      model2 = Model.new(2)
      stream Grape::JSONAPI::Streamer.new([model, model2])
    end
  end
end
```
