class AddPointToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :point, :integer, default: 0
  end
end
