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

ActiveRecord::Schema.define(version: 20220518054750) do

  create_table "managements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "begin_day"
    t.date "finish_day"
    t.boolean "finish_flag"
    t.string "year_p"
    t.string "year_d"
    t.string "year_c"
    t.string "year_a"
    t.string "month_p"
    t.string "month_d"
    t.string "month_c"
    t.string "month_a"
    t.string "week_p"
    t.string "week_d"
    t.string "week_c"
    t.string "week_a"
    t.date "worked_on"
    t.float "study_time"
    t.string "day_p"
    t.string "day_d"
    t.string "day_c"
    t.string "day_a"
    t.integer "user_id"
    t.index ["user_id"], name: "index_managements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "status", default: "applying"
    t.boolean "change", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "ymw_managements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "begin_day"
    t.date "finish_day"
    t.string "year_p"
    t.string "year_d"
    t.string "year_c"
    t.string "year_a"
    t.string "month_p"
    t.string "month_d"
    t.string "month_c"
    t.string "month_a"
    t.string "week_p"
    t.string "week_d"
    t.string "week_c"
    t.string "week_a"
    t.integer "user_id"
    t.string "span"
    t.boolean "finish_flag", default: false, null: false
    t.index ["user_id"], name: "index_ymw_managements_on_user_id"
  end

end
