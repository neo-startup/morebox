class ChangeDefaultOrder < ActiveRecord::Migration[6.0]
  def change
    remove_column :orders, :status
    add_column :orders, :status, :integer, default: 0
  end
end
