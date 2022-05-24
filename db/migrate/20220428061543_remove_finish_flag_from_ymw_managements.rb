class RemoveFinishFlagFromYmwManagements < ActiveRecord::Migration[5.1]
  def change
    remove_column :ymw_managements, :finish_flag, :boolean
  end
end
