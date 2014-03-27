class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :course
      t.string :yummly_id
      t.string :url
      t.string :img_url
      t.integer :number_of_servings
      t.string :source_recipe_url
      t.string :source_display_name
      t.string :fetch_json

      t.timestamps
    end
  end
end
