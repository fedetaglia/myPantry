class AddColumnToShoppingList < ActiveRecord::Migration
  def change
    change_table :shopping_lists do |t|
      t.references :user, index: true 
    end
  end
end
