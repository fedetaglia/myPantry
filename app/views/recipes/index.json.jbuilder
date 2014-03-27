json.array!(@recipes) do |recipe|
  json.extract! recipe, :id, :name, :course, :yummly_id, :url, :img_url, :number_of_servings, :source_recipe_url, :source_display_name, :fetch_json
  json.url recipe_url(recipe, format: :json)
end
