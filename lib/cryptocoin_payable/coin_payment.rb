require 'money-tree'
require 'state_machines-activerecord'

module CryptocoinPayable
  class CoinPayment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: 'CryptocoinPayable::CoinPaymentTransaction'

    validates :reason, presence: true
    validates :price, presence: true
    validates :coin_type, presence: true

    before_create :populate_currency_and_amount_due
    before_create :populate_address

    scope :unconfirmed, -> { where(state: %i[pending partial_payment paid_in_full]) }
    scope :unpaid, -> { where(state: %i[pending partial_payment]) }
    scope :stale, -> { where('updated_at < ? OR coin_amount_due = 0', 30.minutes.ago) }

    # TODO: Duplicated in `CurrencyConversion`.
    enum :coin_type, [:btc, :eth, :bch, :ltc]

    state_machine :state, initial: :pending do
      state :pending
      state :partial_payment
      state :paid_in_full
      state :confirmed
      state :comped
      state :expired

      after_transition on: :pay, do: :notify_payable_paid
      after_transition on: :comp, do: :notify_payable_paid
      after_transition on: :confirm, do: :notify_payable_confirmed
      after_transition on: :expire, do: :notify_payable_expired

      event :pay do
        transition %i[pending partial_payment] => :paid_in_full
      end

      event :partially_pay do
        transition pending: :partial_payment
      end

      event :comp do
        transition %i[pending partial_payment] => :comped
      end

      event :confirm do
        transition paid_in_full: :confirmed
      end

      event :expire do
        transition [:pending] => :expired
      end
    end

    def coin_amount_paid
      transactions.sum { |tx| adapter.convert_subunit_to_main(tx.estimated_value) }
    end

    def coin_amount_paid_subunit
      transactions.sum(&:estimated_value)
    end

    # @returns cents in fiat currency.
    def currency_amount_paid
      cents = transactions.inject(0) do |sum, tx|
        sum + (adapter.convert_subunit_to_main(tx.estimated_value) * tx.coin_conversion)
      end

      # Round to 0 decimal places so there aren't any partial cents.
      cents.round(0)
    end

    def currency_amount_due
      price - currency_amount_paid
    end

    def calculate_coin_amount_due
      adapter.convert_main_to_subunit(currency_amount_due / coin_conversion.to_f).ceil
    end
    
    def coin_conversion
      @coin_conversion ||= CurrencyConversion.where(coin_type: coin_type, currency: currency).last.price
    end
    
    def update_coin_amount_due
      update!(
        coin_amount_due: calculate_coin_amount_due,
        coin_conversion: coin_conversion
      )
    end

    def transactions_confirmed?
      transactions.all? do |t|
        t.confirmations >= CryptocoinPayable.configuration.send(coin_type).confirmations
      end
    end

    def adapter
      @adapter ||= Adapters.for(coin_type)
    end

    private

    def populate_currency_and_amount_due
      self.currency ||= CryptocoinPayable.configuration.currency
      self.coin_amount_due = calculate_coin_amount_due
      self.coin_conversion = coin_conversion
    end

    def populate_address
      self.node_path_id ||= CryptocoinPayable::CoinPayment.select('node_path_id, MAX(created_at) as max_date').where(coin_type: self.coin_type).group(:node_path_id, :coin_type).having('MAX(created_at) < ?', Time.now - 4.day).order(node_path_id: :asc).first.try(:node_path_id) || ((CryptocoinPayable::CoinPayment.where(coin_type: self.coin_type).where('node_path_id IS NOT NULL').order(node_path_id: :desc).first.try(:node_path_id) || 0) + 1)
      self.address = adapter.create_address(self.node_path_id)
    end

    def notify_payable_event(event_name)
      method_name = :"coin_payment_#{event_name}"
      payable.send(method_name, self) if payable.respond_to?(method_name)

      payable.coin_payment_event(self, event_name) if payable.respond_to?(:coin_payment_event)
    end

    def notify_payable_paid
      notify_payable_event(:paid)
    end

    def notify_payable_confirmed
      notify_payable_event(:confirmed)
    end

    def notify_payable_expired
      notify_payable_event(:expired)
    end
  end
end
