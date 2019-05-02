require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Litecoin, :vcr do
  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('32FWnMFma5Bcf3MYZ8VoZSpDtFB9sNhbPj')[0..0]
    expect(response).to eq(
      [
        {
          transaction_hash: 'f76a9147c5b3428092af063c3fd1e54897e78594dd7387e151e153c3544546a4',
          block_hash: nil,
          block_time: nil,
          estimated_time: Time.iso8601('2019-04-26T12:46:06.000000000+02:00'),
          estimated_value: 4_896_269,
          confirmations: 6
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
