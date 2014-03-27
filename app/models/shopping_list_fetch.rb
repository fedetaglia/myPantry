class ShoppingListFetch

 def self.aggregate_ingredients(ingredients)
      aggregate = []
      ingredients.each do |ingredient|
        actual_ingredient = ingredient['ingredient']
        hash_unit_qta = {'unit' => ingredient['unit'], 'qta' => ingredient['qta']}
        ingredient_allocated = false
        aggregate.each do |hash_item|
          if hash_item['ingredient'] == actual_ingredient
            unit_allocated = false
            hash_item['value'].each do |unit|
              key_to_find = hash_unit_qta['unit']
              if unit['unit'] == key_to_find
                unit['qta'] = unit['qta'] + hash_unit_qta['qta']
                unit_allocated = true
              end
            end
            if unit_allocated == false
              hash_item['value'] << hash_unit_qta
            end
            # puts "new hash_item : #{hash_item}"
            ingredient_allocated = true
          end  
        end
        if ingredient_allocated == false
            new_hash = {}
            new_hash['ingredient'] = actual_ingredient
            new_hash['value'] = [hash_unit_qta]
            # puts "#{actual_ingredient} not present"
            # puts "new_hash : #{new_hash}"
            aggregate << new_hash
        end
      end
      return aggregate
    end
end
