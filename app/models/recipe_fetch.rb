class RecipeFetch
  UNITS = ["cups of","cup of","cups","cup","Cups","Cup","tablespoons","ounces","ounce","bunches of", "bunch of", "bunch","tablespoon","teaspoons","teaspoon","lb","pounds","pound","Pinches of","pinches of","Pinches","pinches","pinch of","Pinch of","pinch","Pinch","small","medium","large","whole","thick slices","thick slice","thin slices","thin slice","slices","slice","bottles","bottle","dashes","dashe"]

  def self.get_recipe_from_API(recipe_id)
      answer = HTTParty.get(yummly_url(recipe_id))
      case answer.code
        when 200
          recipe = generate_recipe(recipe_id,answer)
        when 404
          # TODO not found
        when 500...600
          # TODO BOOOM
      end
  end

  def self.yummly_url(recipe_id)
    search = "http://api.yummly.com/v1/api/recipe/#{recipe_id}?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}"
    URI.escape(search)
  end

  def self.generate_recipe(recipe_id,recipe)
    return nil if recipe.nil?  
    ingredients = create_ingredients_hash(recipe)
    recipe['ingredients'] = ingredients     
    new_recipe = Recipe.create(name: recipe['name'], yummly_id: recipe_id, value: JSON.generate(recipe))
    return recipe
  end

  def self.create_ingredients_hash(recipe)
    return [] if !recipe
    hashes_list = []
    ingredients_list = recipe['ingredientLines']
    return [] if !ingredients_list
    ingredients_list.each do |item|
      hashes_list << create_ingredient_part(item)
    end
    return hashes_list
  end

  def self.create_ingredient_part(item)
    part = {'unit' => 'unit','text' => item}
    desc = item.split(',')[0]
    unit = find_unit(desc)
    if unit != nil
      part['qta'], part['ingredient'] = find_ingredient_qty_with_unit(desc.split(unit))
      part['unit'] = unit.gsub(/\s*of\s*\Z/, "").strip # cups of 
    else
      # cant find unit of measure
      part['qta'], part['ingredient'] = find_ingredient_qty_without_unit(desc)  
    end
    part
  end

  def self.find_unit(desc)
    return nil if desc == nil
    UNITS.find{ |u| desc.include? u }
  end

  # ["","Salt"]
  # ["1 1/2", " Tea "] --> [1.5, 'Tea']
  def self.find_ingredient_qty_with_unit(splitted)
    [string_to_number(splitted[0].length > 0 ? splitted[0].strip : ""), splitted[1].strip]
  end

  def self.find_ingredient_qty_without_unit(desc)
    # reg: at the beginning of the string it should have some numbers plus maybe a space followend by a fraction (= some number a / and some other numbers)
    reg = /\A(\d+)(\s*\d+\/\d+)?/ 
    if desc == nil
      res = nil
    else
      res = desc.match(reg)
    end
    if res != nil
      qta = res[0]
      tot = string_to_number(qta)
      ingredient = desc.sub(reg,"").strip # all that not match with reg exp
    else 
      tot = 1
      ingredient = desc
    end
    return [tot, ingredient]
  end

  def self.string_to_number(qta)
    if qta.include? '/' # type: "1/2" or "1 1/2"
      tot = fractional_to_number(qta)
    else
      tot = qta.to_f == 0 ? 1.0 : qta.to_f
    end
  end

  def self.fractional_to_number(qta)
    if !qta.include?"/"
      regx = /\d*(\.\d+)?/
      qta = qta.match regx 
      if qta[0] != ""
        return qta[0].to_f
      else
        return 1
      end
    else
      int = 0
      if qta.include? " " # "1 1/2"
        int,qta  = qta.split(" ")
      end
      num,den = qta.split('/').map(&:to_f)
      num == 0 ? 1 : ( num ||= 1 )
      den ||= 1
      tot = num/den
      tot = tot + int.to_f
    end
  end
end