module CryptocoinPayable
  class CurrencyConversion < ActiveRecord::Base
    validates :price, presence: true

    # TODO: Duplicated in `CoinPayment`.
    enum coin_type: %i[
      btc
      eth
      bch
      ltc
    ]
    
    # def self.fetch_rates
    #   CurrencyRate.sync_crypto!
    #   CurrencyRate.sync_fiat!
      
    #   CryptocoinPayable::CurrencyConversion.coin_types.each do |coin_type|
    #     CryptocoinPayable::CurrencyConversion.create!(
    #         currency: 'usd',
    #         price: (CurrencyRate.fetch_crypto("Kraken", coin_type[0], "USD") * 100.0).round,
    #         coin_type: coin_type[0]
    #       )
    #   end
    # end
  end
end
