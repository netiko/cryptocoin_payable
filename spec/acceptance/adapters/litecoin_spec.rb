require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Litecoin, :vcr do
  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('32FWnMFma5Bcf3MYZ8VoZSpDtFB9sNhbPj')[0..0]
    expect(response).to eq(
      [
        {
          transaction_hash: '5bdeaf7829148d7e0e1e7b5233512a2c5ae54ef7ccbc8e68b2f85b7e49c917a0',
          block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
          block_time: Time.iso8601('2016-09-13T15:41:00Z'),
          estimated_time: Time.iso8601('2016-09-13T15:33:29.126Z'),
          estimated_value: 0,
          confirmations: 116077
        }
      ]
    )
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('Lbc8949Dht4Ps7o4B7Nn4Ld4fA6vk19qH3')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  it 'creates BIP32 addresses' do
    
    3.times do
      expect(subject.create_address(0)).to eq('LMfPaut9zTDQW9XsEzsY95M32HEPwfhSQ4')
      expect(subject.create_address(1)).to eq('Lbc8949Dht4Ps7o4B7Nn4Ld4fA6vk19qH3')
      expect(subject.create_address(2)).to eq('Lbbvr5ZaKuPr11V9qZC6gVgKAGsV79hDrZ')
    end
  end
end
