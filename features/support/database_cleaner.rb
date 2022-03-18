require 'database_cleaner/active_record'

    ENV['RAILS_ENV'] = 'test'
    load 'spec/dummy/db/schema.rb'
  
  at_exit do
    %i[
      coin_payment_transactions
      coin_payments
      currency_conversions
      widgets
      ar_internal_metadata
      schema_migrations
    ].each do |table_name|
      ActiveRecord::Base.connection.drop_table(table_name)
    end
  end

DatabaseCleaner.strategy = :truncation
Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end