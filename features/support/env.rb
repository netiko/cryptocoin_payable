ENV['RAILS_ENV'] ||= 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '../../../spec/dummy'

require 'cucumber/rails'
require 'cucumber/rspec/doubles'

# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.

Before do
  3.times do
    CryptocoinPayable::CurrencyConversion.create!(
      coin_type: :btc,
      currency: :usd,
      price: rand(10_000...15_000) * 100, # cents in fiat
    )
  end
  @currency_conversions = CryptocoinPayable::CurrencyConversion.all
end
