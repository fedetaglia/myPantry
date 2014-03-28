class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  # GET /recipes.json
  def index
    @recipes = Recipe.all
  end



  def search
    @search_parameter = Search.load_search_parameters()
    course_id = params["course"]
    course = JSON.parse(@search_parameter['course'].value).select {|course| course['id'] == course_id}
    course_search_key = course[0]['searchValue']
    search = "https://api.yummly.com/v1/api/recipes?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}&q="
    courses = "&allowedCourse[]=#{course_search_key}"
    number_of_recipes = "&maxResult=14"
    requirepicture = "&requirePictures=true"

    string = search + courses + number_of_recipes + requirepicture
    answer = HTTParty.get(URI.escape(string))
    if answer['matches'].count != 0
      @dishes_json = answer['matches']
    end
    render json: @dishes_json 
  end



  def search_detail
    people = params['aggregator']['people'].to_i
    days = params['aggregator']['days'].to_i
    meals = []
    meals << {'name' => 'breakfast', 'ids' => params['aggregator']['selectedBreakfasts'] || [] }
    meals << {'name' => 'lunch', 'ids' => params['aggregator']['selectedLunches'] || [] }
    meals << {'name' => 'appetizer', 'ids' => params['aggregator']['selectedAppetizers'] || [] }
    meals << {'name' => 'dinner', 'ids' => params['aggregator']['selectedDinners'] || [] }
    meals << {'name' => 'drink', 'ids' => params['aggregator']['selectedDrinks'] || [] }

    servings_needed = people * days
    
    @ingredients = {} # 
    @servings = {} # hash with keys: dish_id and value: numberOfServings
    
    meals.each do |meal|
      ids = meal['ids']
      dishes_name = []
      ingredients = {} # hash with keys dish_id and value:[hash of ingredients]
      ids.each do |dish_id|
        recipe = Recipe.find_by_yummly_id dish_id
        if recipe != nil
          found_recipe = JSON.parse(recipe.value)
          dishes_name << found_recipe['name']
          @servings[dish_id] = found_recipe['numberOfServings'].to_i
          ingredients[dish_id] = found_recipe['ingredients']
        else
          if recipe = RecipeFetch.get_recipe_from_API(dish_id)
            dishes_name << recipe['name']
            @servings[dish_id] = recipe['numberOfServings'].to_i
            ingredients[dish_id] = recipe['ingredients']
          else
            # TODO rise error 
          end
        end  
      end
      meal['dishes'] = dishes_name
      adapted_ingredients = IngredientFetch.calculate_ingredients_needed(meal['ids'],servings_needed,@servings,ingredients)
      adapted_ingredients.each do |key,value|
        if !@ingredients.has_key?(key)
          @ingredients[key]  = value
        else
          # TODO sum up the ingredient with the previous one
        end
      end

    end
    @shopping_list = {}
    @shopping_list['meals'] = meals
    @shopping_list['ingredient'] = ShoppingListFetch.aggregate_ingredients(@ingredients.values.flatten)

    render json: @shopping_list
    
  end


  def show

  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  # POST /recipes.json
  def create
    @recipe = Recipe.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: 'Recipe was successfully created.' }
        format.json { render action: 'show', status: :created, location: @recipe }
      else
        format.html { render action: 'new' }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to @recipe, notice: 'Recipe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.require(:recipe).permit(:name, :yummly_id, :value)
  end
end
