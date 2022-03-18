# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_25_190042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"

  create_table "coin_payment_transactions", force: :cascade do |t|
    t.decimal "estimated_value", precision: 24
    t.string "transaction_hash"
    t.string "block_hash"
    t.datetime "block_time"
    t.datetime "estimated_time"
    t.integer "coin_payment_id"
    t.decimal "coin_conversion", precision: 24
    t.integer "confirmations", default: 0
    t.index ["coin_payment_id"], name: "index_coin_payment_transactions_on_coin_payment_id"
    t.index ["transaction_hash"], name: "index_coin_payment_transactions_on_transaction_hash", unique: true
  end

  create_table "coin_payments", force: :cascade do |t|
    t.string "payable_type"
    t.integer "coin_type"
    t.integer "payable_id"
    t.string "currency"
    t.string "reason"
    t.bigint "price"
    t.decimal "coin_amount_due", precision: 24, default: "0"
    t.string "address"
    t.string "state", default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "coin_conversion", precision: 24
    t.integer "node_path_id"
    #t.index "coin_type, node_path_id, tsrange(created_at, (created_at + 'P4D'::interval), '[]'::text)", name: "unique_node_path_id_within_4_days", using: :gist
    t.index ["coin_type", "node_path_id", "created_at"], name: "index_coin_payments_on_coin_type_node_path_id_created_at", order: { created_at: :desc }
    t.index ["payable_type", "payable_id"], name: "index_coin_payments_on_payable_type_and_payable_id"
  end

    ################TO ADD MANUALLY
    ActiveRecord::Base.connection.execute 'ALTER TABLE coin_payments 
    ADD CONSTRAINT unique_node_path_id_within_4_days
      EXCLUDE  USING gist
      ( coin_type WITH =,
        node_path_id WITH =, 
        tsrange(created_at,  (created_at + interval \'4 days\'), \'[]\') WITH &&
      );'
    ################
  create_table "currency_conversions", force: :cascade do |t|
    t.string "currency"
    t.decimal "price", precision: 24
    t.integer "coin_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "widgets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
