class Search < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :name
      t.text :value

      t.timestamps
    end
  end
end
