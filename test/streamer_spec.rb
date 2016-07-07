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
    params do
      optional :limit, type: Integer
    end
    get do
      models = [Model.new(1), Model.new(2)]
      if params[:limit]
        options = { 'meta' => { 'total-records' => 100 }, 'links' => { 'self' => '/foo?limit=2' } }
        stream Grape::JSONAPI::Streamer.new(models, options)
      else
        stream Grape::JSONAPI::Streamer.new(models)
      end
    end
  end
end

class StreamerSpec < Minitest::Spec
  include Rack::Test::Methods

  def app
    MockAPI
  end

  context 'when no options' do
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

  context 'when meta and links options provided' do
    let(:body) do
      {
        'meta' => {
          'total-records' => 100
        },
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
        ],
        'links' => {
          'self' => '/foo?limit=2'
        }
      }
    end

    it 'should output json response' do
      get '/foo?limit=2'

      assert_equal body, JSON.parse(last_response.body)
      assert_equal 200, last_response.status
    end
  end
end
