class AddPhoneToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :phone, :integer
  end
end
