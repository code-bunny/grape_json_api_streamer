# frozen_string_literal: true
require_relative './test_helper'
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

class StreamerSpec < Minitest::Spec
  include Rack::Test::Methods

  def app
    MockAPI
  end

  let(:body) do
    {
      'data' => [
        {
          'type'       => 'models',
          'id'         => '1',
          'attributes' => { 'foo'  => 'bar' },
          'links'      => { 'self' => '/models/1' }
        }, {
          'type'       => 'models',
          'id'         => '2',
          'attributes' => { 'foo'  => 'bar' },
          'links'      => { 'self' => '/models/2' }
        }
      ]
    }
  end

  it 'should output json response' do
    get '/foo'

    assert_equal body, JSON.parse(last_response.body)
    assert_equal 200, last_response.status
  end
end
