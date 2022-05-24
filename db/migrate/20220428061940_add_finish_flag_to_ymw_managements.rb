class AddFinishFlagToYmwManagements < ActiveRecord::Migration[5.1]
  def change
    add_column :ymw_managements, :finish_flag, :boolean, default: false, null: false
  end
end
