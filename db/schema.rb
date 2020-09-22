# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_22_033634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_comments_on_item_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "gyms", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "gyms_sub_items", force: :cascade do |t|
    t.integer "gym_id"
    t.integer "sub_item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity", default: 0
  end

  create_table "items", force: :cascade do |t|
    t.string "title"
    t.integer "price"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image2"
    t.integer "count"
    t.integer "point", default: 0
  end

  create_table "order_sub_items", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "sub_item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity"
    t.index ["order_id"], name: "index_order_sub_items_on_order_id"
    t.index ["sub_item_id"], name: "index_order_sub_items_on_sub_item_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "number"
    t.integer "total"
    t.string "address1"
    t.string "address2"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "payment_method"
    t.string "order_name"
    t.string "order_phone"
    t.string "order_email"
    t.string "deliver_name"
    t.string "deliver_phone"
    t.string "bank"
    t.string "bank_owner"
    t.string "bank_account"
    t.string "requirement"
    t.bigint "gym_id"
    t.bigint "item_id"
    t.integer "before_point", default: 0
    t.bigint "point_id"
    t.integer "status", default: 0
    t.datetime "paid_at"
    t.integer "payment_amount"
    t.string "tid"
    t.string "order_number"
    t.bigint "trainer_id"
    t.index ["gym_id"], name: "index_orders_on_gym_id"
    t.index ["item_id"], name: "index_orders_on_item_id"
    t.index ["point_id"], name: "index_orders_on_point_id"
    t.index ["trainer_id"], name: "index_orders_on_trainer_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.integer "amount"
    t.integer "point_type"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "sub_item_id"
    t.integer "remain_point"
    t.bigint "gym_id"
    t.index ["gym_id"], name: "index_points_on_gym_id"
    t.index ["sub_item_id"], name: "index_points_on_sub_item_id"
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "sub_items", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "point", default: 0
    t.bigint "category_id"
    t.text "description"
    t.float "calorie"
    t.float "carbo"
    t.float "protein"
    t.float "fat"
    t.index ["category_id"], name: "index_sub_items_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone"
    t.string "username"
    t.boolean "fit_center"
    t.string "email", default: "", null: false
    t.bigint "gym_id", null: false
    t.integer "gender"
    t.boolean "privacy", default: true
    t.string "referrer"
    t.boolean "marketing", default: true
    t.integer "user_type", default: 0
    t.index ["gym_id"], name: "index_users_on_gym_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "items"
  add_foreign_key "comments", "users"
  add_foreign_key "order_sub_items", "orders"
  add_foreign_key "order_sub_items", "sub_items"
  add_foreign_key "orders", "gyms"
  add_foreign_key "orders", "items"
  add_foreign_key "orders", "points"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "trainer_id"
  add_foreign_key "points", "gyms"
  add_foreign_key "points", "sub_items"
  add_foreign_key "points", "users"
  add_foreign_key "sub_items", "categories"
  add_foreign_key "users", "gyms"
end
