module CryptocoinPayable
  class PricingProcessor
    def self.perform
      new.perform
    end

    def self.delete_currency_conversions(time_ago)
      new.delete_currency_conversions(time_ago)
    end

    def perform
      
      
=begin
      rates = CurrencyConversion.coin_types.map do |coin_pair|
        coin_type = coin_pair[0].to_sym
        [
          coin_type,
          CurrencyConversion.create!(
            # TODO: Store three previous price ranges, defaulting to 100 for now.
            currency: 100,
            price: Adapters.for(coin_type).fetch_rate,
            coin_type: coin_type
          )
        ]
      end.to_h
  
=end

      # Loop through all unpaid payments and update them with the new price if
      # it has been 30 mins since they have been updated.
      CoinPayment.unpaid.stale.find_each do |payment|
        payment.update_coin_amount_due
      end
    end

    def delete_currency_conversions(time_ago)
      # Makes sure to keep at least one record in the db since other areas of
      # the gem assume the existence of at least one record.
      last_id = CurrencyConversion.last.id
      time = time_ago || 1.month.ago
      CurrencyConversion.where('created_at < ? AND id != ?', time, last_id).delete_all
    end
  end
end
