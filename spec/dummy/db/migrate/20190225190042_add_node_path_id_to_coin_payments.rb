class AddNodePathIdToCoinPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :coin_payments, :node_path_id, :integer
    CryptocoinPayable::CoinPayment.update_all('node_path_id = id')
    
    ActiveRecord::Base.connection.add_index :coin_payments, ['coin_type', 'node_path_id', 'created_at'], order: {'coin_type'=>:asc, 'node_path_id'=>:asc, 'created_at'=>:desc}, name: :index_coin_payments_on_coin_type_node_path_id_created_at, using: :btree

    #ActiveRecord::Base.connection.execute 'CREATE EXTENSION btree_gist;'
    ActiveRecord::Base.connection.execute 'ALTER TABLE coin_payments 
  ADD CONSTRAINT unique_node_path_id_within_4_days
    EXCLUDE  USING gist
    ( coin_type WITH =,
      node_path_id WITH =, 
      tsrange(created_at,  (created_at + interval \'4 days\'), \'[]\') WITH &&
    );'
  end
end
