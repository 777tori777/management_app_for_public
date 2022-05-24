class ChangeStatusDefaultOnUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :status, from: "applying", to: "applying"
  end
end
