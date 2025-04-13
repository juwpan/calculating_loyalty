require 'sequel'
require 'sinatra'
require 'json'

require_relative './models/operation_confirm'
require_relative './models/operation_calculate'
require_relative './service/user_repository'
require_relative './service/position_builder'
require_relative './service/operation_create'
require_relative './service/operation_response_builder'
require_relative './service/calculate/discount_calculate'
require_relative './service/calculate/cashback_calculate'

class BasicApp < Sinatra::Base
  DB = Sequel.connect('sqlite://db/test.db')

  post '/operation' do
    process_request(OperationCalculate)
  end

  post '/submit' do
    process_request(OperationConfirm)
  end

  private

  def process_request(service_class)
    begin
      payload = JSON.parse(request.body.read, symbolize_names: true)
      result = service_class.new(payload, DB).call

      content_type :json
      return JSON.generate(result)
    rescue StandardError => e
      status 500
      content_type :json
      return { error: e.message }.to_json
    end
  end
end
