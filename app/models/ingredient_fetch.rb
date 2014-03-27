class IngredientFetch
  
  def self.calculate_ingredients_needed(meal,servings_needed,servings,ingredients)
    meal.each do |bre|
      ingredients[bre].each do |ingredient|
        ingredient['qta'] = calculate_ingredient_qta(ingredient['qta'],servings_needed,meal,servings)
      end
    end
    return ingredients
  end

  def self.calculate_ingredient_qta(original_qty,servings_needed,meal,servings)
    selected = servings_selected(meal,servings)
    if selected == 0
      0
    else      
      servings_ratio = servings_needed / selected
      ( (original_qty.to_f) * servings_ratio ).round(1) 
    end
  end

  def self.servings_selected(meal,servings)
    servings_selected = 0.0
    meal.each do |bre|
      servings_selected = servings_selected + servings[bre]
    end
    servings_selected
  end


end