require 'active_record'
require 'cryptocoin_payable'
require 'cryptocoin_payable/orm/activerecord'

require 'pry'


describe CryptocoinPayable::CoinPayment do
  context 'when creating a Bitcoin Cash payment' do
    subject { CryptocoinPayable::CoinPayment.new(coin_type: :bch, reason: 'test', price: 1, currency: :usd) }
    let(:subject_2) { CryptocoinPayable::CoinPayment.new(coin_type: :bch, reason: 'test', price: 1, currency: :usd) }

    it 'can save a payment' do
      expect { subject.save! }.not_to raise_error
    end

    it 'can update the coin amount due' do
      subject.update_coin_amount_due
      expect(subject.coin_amount_due).to eq(100_000_000)
      expect(subject.coin_conversion).to eq(1)
    end

    it 'generates node_path_id' do
      subject.save
      subject_2.save

      expect(subject.node_path_id).to eq(3)
      expect(subject_2.node_path_id).to eq(4)
    end
    
    it 'generates node_path_id when more than 4 days' do
      subject.created_at = Time.now - 5.days
      subject.save
      subject_2.save
      expect(subject.node_path_id).to eq(5)
      expect(subject_2.node_path_id).to eq(5)
    end

    it 'raise error if duplicate node_path_id within 4 days' do
      subject_2.node_path_id = 1
      subject.save
      expect { subject_2.save! }.to raise_error
    end
  end
end
