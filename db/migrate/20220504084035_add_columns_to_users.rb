class AddColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :status, :string, default: "applying"
    add_column :users, :change, :boolean, default: false, null: false
  end
end
