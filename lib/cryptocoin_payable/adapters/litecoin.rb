module CryptocoinPayable
  module Adapters
    class Litecoin < Bitcoin
      def self.coin_symbol
        'LTC'
      end

      def fetch_transactions(address)
        fetch_block_cypher_transactions(address)
      end

      private

      def prefix
        CryptocoinPayable.configuration.testnet ? 'TEST' : ''
      end

      def network
        CryptocoinPayable.configuration.testnet ? :litecoin_testnet : :litecoin
      end

      def fetch_block_cypher_transactions(address)
        url = "https://api.blockcypher.com/v1/ltc/main/addrs/#{address}/full"
        parse_block_cypher_transactions(get_request(url).body, address)
      end
    end
  end
end