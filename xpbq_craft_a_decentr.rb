require 'json'
require 'httparty'
require 'graphql'

class DecentralizedDataVisualizationTracker
  def initialize
    @contracts = []
    @data = {}
  end

  def add_contract(contract_address)
    @contracts << contract_address
  end

  def fetch_data
    @contracts.each do |contract_address|
      response = HTTParty.get("https://api.etherscan.io/api?module=account&action=txlist&address=#{contract_address}&startblock=0&endblock=99999999&sort=desc&apikey=YOUR_API_KEY")
      data = JSON.parse(response.body)
      data['result'].each do |tx|
        @data[tx['hash']] = {
          from: tx['from'],
          to: tx['to'],
          value: tx['value'],
          timestamp: tx['timeStamp']
        }
      end
    end
  end

  def visualize_data
    GraphQL::Schema.define do
      query do
        field :data, !types.Hash do
          resolve ->(obj, args, ctx) {
            @data
          }
        end
      end
    end
    Schema = GraphQL::Schema
    result = Schema.execute('{ data }')
    puts JSON.pretty_generate(result.to_h)
  end
end

tracker = DecentralizedDataVisualizationTracker.new
tracker.add_contract('0x742d35Cc6634C0532925a3b844Bc454e4438f44e')
tracker.add_contract('0xB97048628dB65698aeF3C6529413dF5C43d4Ea44')
tracker.fetch_data
tracker.visualize_data