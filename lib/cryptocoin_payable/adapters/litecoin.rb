module CryptocoinPayable
  module Adapters
    class Litecoin < Bitcoin
      def self.coin_symbol
        'LTC'
      end

      def fetch_transactions(address)

        url = "https://chain.so/api/v2/address/LTC#{prefix}/#{address}"
        parse_block_explorer_transactions(get_request(url).body, address)
      end

      private

      def prefix
        CryptocoinPayable.configuration.testnet ? 'TEST' : ''
      end

      def network
        CryptocoinPayable.configuration.testnet ? :litecoin_testnet : :litecoin
      end

      def parse_total_tx_value_block_explorer(output_transactions, address)
        output_transactions ? (output_transactions['value'].to_f * self.class.subunit_in_main).to_i : 0
      end

      def parse_block_explorer_transactions(response, address)
        json = JSON.parse(response)
        raise ApiError, json['message'] if json['code'] == 404
        json['data']['txs'].reject { |tx| tx['incoming'].nil? }.map { |tx| convert_block_explorer_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError, response
      end

      def convert_block_explorer_transactions(transaction, address)
        {
          transaction_hash: transaction['txid'],
          block_hash: nil, # Not supported
          block_time: nil, # Not supported
          estimated_time: parse_timestamp(transaction['time']),
          estimated_value: parse_total_tx_value_block_explorer(transaction['incoming'], address),
          confirmations: transaction['confirmations']
        }
      end
    end
  end
end
