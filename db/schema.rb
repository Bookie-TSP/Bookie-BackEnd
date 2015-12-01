# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151118091526) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "information"
    t.integer  "member_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "addresses", ["member_id"], name: "index_addresses_on_member_id", using: :btree

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.string   "ISBN10"
    t.string   "ISBN13"
    t.text     "authors"
    t.string   "language"
    t.integer  "pages"
    t.string   "publisher"
    t.date     "publish_date"
    t.string   "description"
    t.string   "cover_image_url"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["member_id"], name: "index_carts_on_member_id", using: :btree

  create_table "carts_stocks", id: false, force: :cascade do |t|
    t.integer "cart_id",  null: false
    t.integer "stock_id", null: false
  end

  add_index "carts_stocks", ["cart_id", "stock_id"], name: "index_carts_stocks_on_cart_id_and_stock_id", using: :btree
  add_index "carts_stocks", ["stock_id", "cart_id"], name: "index_carts_stocks_on_stock_id_and_cart_id", using: :btree

  create_table "line_stocks", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "book_id"
    t.integer  "quantity"
    t.string   "type"
    t.float    "price"
    t.string   "condition"
    t.string   "duration"
    t.string   "terms"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "line_stocks", ["book_id"], name: "index_line_stocks_on_book_id", using: :btree
  add_index "line_stocks", ["member_id"], name: "index_line_stocks_on_member_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "identification_number"
    t.string   "gender"
    t.date     "birth_date"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "auth_token",             default: ""
  end

  add_index "members", ["auth_token"], name: "index_members_on_auth_token", unique: true, using: :btree
  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
  add_index "members", ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "address_id"
    t.string   "status"
    t.string   "side"
    t.float    "total_price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "orders", ["address_id"], name: "index_orders_on_address_id", using: :btree
  add_index "orders", ["member_id"], name: "index_orders_on_member_id", using: :btree

  create_table "orders_stocks", id: false, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "stock_id", null: false
  end

  add_index "orders_stocks", ["order_id", "stock_id"], name: "index_orders_stocks_on_order_id_and_stock_id", using: :btree
  add_index "orders_stocks", ["stock_id", "order_id"], name: "index_orders_stocks_on_stock_id_and_order_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "billing_name"
    t.string   "billing_type"
    t.string   "billing_card_number"
    t.string   "billing_card_expire_date"
    t.integer  "billing_card_security_number"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "line_stock_id"
    t.integer  "member_id"
    t.string   "status"
    t.float    "price"
    t.string   "type"
    t.string   "condition"
    t.string   "duration"
    t.string   "terms"
    t.string   "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "stocks", ["book_id"], name: "index_stocks_on_book_id", using: :btree
  add_index "stocks", ["line_stock_id"], name: "index_stocks_on_line_stock_id", using: :btree

  add_foreign_key "addresses", "members"
  add_foreign_key "carts", "members"
  add_foreign_key "line_stocks", "books"
  add_foreign_key "line_stocks", "members"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "members"
  add_foreign_key "payments", "orders"
  add_foreign_key "stocks", "books"
  add_foreign_key "stocks", "line_stocks"
end
