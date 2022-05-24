class CreateYmwManagements < ActiveRecord::Migration[5.1]
  def change
    create_table :ymw_managements do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.date :begin_day
      t.date :finish_day
      t.boolean :finish_flag
      t.string :year_p
      t.string :year_d
      t.string :year_c
      t.string :year_a
      t.string :month_p
      t.string :month_d
      t.string :month_c
      t.string :month_a
      t.string :week_p
      t.string :week_d
      t.string :week_c
      t.string :week_a
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
