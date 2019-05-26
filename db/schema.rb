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

ActiveRecord::Schema.define(version: 20190523112650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignations", force: :cascade do |t|
    t.integer "sku"
    t.string "name"
    t.integer "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "ingredients", force: :cascade do |t|
    t.integer "sku_product"
    t.string "name_product"
    t.integer "sku_ingredient"
    t.string "name_ingredient"
    t.float "quantity"
    t.string "unit1"
    t.integer "production_lot"
    t.float "quantity_for_lot"
    t.string "unit2"
    t.float "equivalence_unit_hold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", force: :cascade do |t|
    t.integer "id_caso"
    t.string "activity"
    t.integer "group"
    t.integer "sku"
    t.integer "price"
    t.string "status"
  end

  create_table "minimum_stocks", force: :cascade do |t|
    t.integer "sku"
    t.string "name"
    t.integer "number_of_products"
    t.integer "minimum_stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_jokes", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "sku"
    t.string "name"
    t.string "description"
    t.integer "sell_price"
    t.integer "ingredients"
    t.integer "used_by"
    t.float "expected_duration_hours"
    t.float "equivalence_units_hold"
    t.string "unit"
    t.string "production_lot"
    t.float "expected_time_production_mins"
    t.string "groups"
    t.integer "total_productor_groups"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "incoming"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer "sku"
    t.string "name"
    t.string "description"
    t.integer "ingredients_number"
    t.string "ingredient1"
    t.string "ingredient2"
    t.string "ingredient3"
    t.string "ingredient4"
    t.string "ingredient5"
    t.string "ingredient6"
    t.integer "space_for_production"
    t.integer "space_for_receive_production"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
