class ChangeRecipeTable < ActiveRecord::Migration
  def change
    remove_column :recipes, :course
    remove_column :recipes, :url
    remove_column :recipes, :img_url
    remove_column :recipes, :number_of_servings
    remove_column :recipes, :source_recipe_url
    remove_column :recipes, :source_display_name
    remove_column :recipes, :fetch_json
    add_column :recipes, :value, :text
  end
end
