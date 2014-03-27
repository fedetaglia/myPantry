class CreateShoppingLists < ActiveRecord::Migration
  def change
    create_table :shopping_lists do |t|
      t.string :name
      t.text :aggregator
      t.text :ingredients

      t.timestamps
    end
  end
end
