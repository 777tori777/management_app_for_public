class AddSpanToYmwManagements < ActiveRecord::Migration[5.1]
  def change
    add_column :ymw_managements, :span, :string
  end
end
