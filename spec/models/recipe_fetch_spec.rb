require 'spec_helper'

describe RecipeFetch do
  let(:recipe) { { 'ingredientLines'=> ['2 cups of tea'] } }

  context '#get_recipe_from_API' do 
    it ('should call generate_recipe if httparty return 200') do
      allow(RecipeFetch).to receive(:generate_recipe).and_return('whatever')
      allow(RecipeFetch).to receive(:yummly_url).and_return('whatever')
      allow(HTTParty).to receive(:get).and_return(double({code: 200}))
      expect(RecipeFetch).to receive(:generate_recipe)
      RecipeFetch.get_recipe_from_API('recipe_id')
    end

    it "should call HTTParty.get" do 
      allow(RecipeFetch).to receive(:generate_recipe).and_return('whatever')
      allow(RecipeFetch).to receive(:yummly_url).and_return('whatever')
      expect(HTTParty).to receive(:get).with("whatever").and_return(double({code: 200}))
      RecipeFetch.get_recipe_from_API('recipe_id')
    end

    it "should call yummly_url with recipe_id" do
      allow(RecipeFetch).to receive(:generate_recipe).and_return('whatever')
      allow(HTTParty).to receive(:get).and_return(double({code: 200}))
      expect(RecipeFetch).to receive(:yummly_url).with('recipe_id').and_return('whatever')
      RecipeFetch.get_recipe_from_API('recipe_id')
    end
  end

  context '#yummly_url' do
    it 'call URI.escape with any arguments' do 
      expect(URI).to receive(:escape)
      RecipeFetch.yummly_url('id')
    end
    context 'the result' do 
      it 'should match api.yummly.com ' do 
        expect(RecipeFetch.yummly_url('id')).to match(/api.yummly.com/)
      end
      it 'should match recipe_id' do 
        expect(RecipeFetch.yummly_url('Blablabla')).to match(/Blablabla/)
      end
    end
  end

  context '#generate_recipe' do
    it ("should call the create_ingredients_hash with the input 'answer' ") do
      expect(RecipeFetch).to receive(:create_ingredients_hash).with({'answer'=>"ok"}).and_return("wherever")
      RecipeFetch.generate_recipe('id',{'answer'=>"ok"})
    end

    it "should return nil if recipe is nil" do 
      expect(RecipeFetch.generate_recipe('id',nil)).to eq(nil)
    end

    context 'allow create_ingredients_hash' do 
      before(:each) do 
        @ingredients = [{'qta' =>1, 'ingredient' => 'tea'}]
        allow(RecipeFetch).to receive(:create_ingredients_hash).and_return(@ingredients)
      end
      it "should put ingredient into the recipe ingredients" do
        rec = RecipeFetch.generate_recipe('id',{})
        expect(rec['ingredients']).to eq(@ingredients)
      end
      it "should create a new recipe" do 
        recipe = {'name' => 'name'}
        expect(Recipe).to receive(:create).with({name: 'name', yummly_id: 'id', value: JSON.generate(recipe.merge({'ingredients' => @ingredients}))})
        RecipeFetch.generate_recipe('id',recipe)
      end
    end
  end

  context'#create_ingredients_hash' do
    it ("should call create_ingredient_part if input contain a 'ingredientLines' key ") do
      expect(RecipeFetch).to receive(:create_ingredient_part).with('2 cups of tea').and_return({'qta'=>2,'unit'=>'cups','ingredient'=>'tea','text'=>'2 cups of tea'})
      RecipeFetch.create_ingredients_hash(recipe)
    end

    it("should return an hash of inredient if passing a recipe") do
      allow(RecipeFetch).to receive(:create_ingredient_part).with('2 cups of tea').and_return({'qta'=>2,'unit'=>'cups','ingredient'=>'tea','text'=>'2 cups of tea'})
      expect(RecipeFetch.create_ingredients_hash(recipe)).to eq([{'qta'=>2,'unit'=>'cups','ingredient'=>'tea','text'=>'2 cups of tea'}])
    end

    it("should return an empty array if passing a string that is not a recipe") do
      expect(RecipeFetch.create_ingredients_hash('bla')).to eq([])
    end

    it("should return an empty array if passing a an empty string") do
      expect(RecipeFetch.create_ingredients_hash('')).to eq([])
    end

    it("should return an empty array if passing a a nil value") do
      expect(RecipeFetch.create_ingredients_hash(nil)).to eq([])
    end
  end

  context "#create_ingredient_part" do 
    it ("should call find_unit with '2 cups of tea' if input is '2 cups of tea, hot or cold'") do 
      expect(RecipeFetch).to receive(:find_unit).with('2 cups of tea').and_return('cups')
      RecipeFetch.create_ingredient_part('2 cups of tea, hot or cold')
    end

    it ("should call find_ingredient_qty_with_unit if input is '2 cups of tea' ") do 
      allow(RecipeFetch).to receive(:find_unit).with('2 cups of tea').and_return('cups of')
      expect(RecipeFetch).to receive(:find_ingredient_qty_with_unit).with(['2 ',' tea']).and_return([2,'tea'])
      RecipeFetch.create_ingredient_part('2 cups of tea, hot or cold')
    end

    it ("should call find_ingredient_qty_without_unit if input is '2 meats toghether'") do 
      allow(RecipeFetch).to receive(:find_unit).with('2 meats toghether').and_return(nil)
      expect(RecipeFetch).to receive(:find_ingredient_qty_without_unit).with('2 meats toghether').and_return([2,'meats toghether'])
      RecipeFetch.create_ingredient_part('2 meats toghether')
    end

    it ("should return [2,'meats toghether'] if input is '2 meats toghether'") do 
      allow(RecipeFetch).to receive(:find_unit).with('2 meats toghether').and_return(nil)
      allow(RecipeFetch).to receive(:find_ingredient_qty_without_unit).with('2 meats toghether').and_return([2,'meats toghether'])
      RecipeFetch.create_ingredient_part('2 meats toghether')
    end

    it ("should return [1.5,'tea'] if input is '1 1/2 cups of tea'") do 
      allow(RecipeFetch).to receive(:find_unit).with('1 1/2 cups of tea').and_return(nil)
      allow(RecipeFetch).to receive(:find_ingredient_qty_with_unit).with(['1 1/2','tea']).and_return([1.5,'tea'])
      RecipeFetch.create_ingredient_part('1 1/2 cups of tea')
    end

    it ("should return ??? if input is ''") do 
      allow(RecipeFetch).to receive(:find_unit).with(nil).and_return(nil)
      allow(RecipeFetch).to receive(:find_ingredient_qty_without_unit).with(nil).and_return([1,'tea'])
      RecipeFetch.create_ingredient_part('')
    end
  end

  context '#find_unit' do
    it ("should return nil if input is empty") do
      expect(RecipeFetch.find_unit("")).to eq(nil)
    end

    it ("should return 'cups of' if the input is '2 cups of tea' ") do
      expect(RecipeFetch.find_unit('2 cups of tea')).to eq('cups of')
    end

    it ("should return nil if the input is '2 meats' ") do
      expect(RecipeFetch.find_unit('2 meats')).to eq(nil)
    end

    it ("should return nil if the input is nil") do
      expect(RecipeFetch.find_unit(nil)).to eq(nil)
    end
  end

  context "#find_ingredient_qty_with_unit" do
    it ("should call string_to_number with first element .strip of the input array if it's not 0 ") do 
      expect(RecipeFetch).to receive(:string_to_number).with("1 1/2").and_return(0.5)
      RecipeFetch.find_ingredient_qty_with_unit(["1 1/2 ","b"])
    end

    it ("should call string_to_number with 1 if length of first element of array is 0 ") do 
      expect(RecipeFetch).to receive(:string_to_number).with("").and_return(1)
      RecipeFetch.find_ingredient_qty_with_unit(["","b"])
    end

    it ("should return an array with 1 and 'Blablabla' if passing ['1 1/2','Blablabla'] ") do 
      allow(RecipeFetch).to receive(:string_to_number).with("1 1/2").and_return(1.5)
      expect( RecipeFetch.find_ingredient_qty_with_unit(["1 1/2"," Blablabla "]) ).to eq([1.5,"Blablabla"])
    end

    it ("should return an array with 1 and 'Blablabla' if passing ['','Blablabla'] ") do 
      allow(RecipeFetch).to receive(:string_to_number).with("").and_return(1)
      expect( RecipeFetch.find_ingredient_qty_with_unit([""," Blablabla "]) ).to eq([1,"Blablabla"])
    end


    it ("should return an array with 1 and 'Blablabla' if passing [' ','Blablabla'] ") do 
      allow(RecipeFetch).to receive(:string_to_number).with("").and_return(1)
      expect( RecipeFetch.find_ingredient_qty_with_unit([" "," Blablabla "]) ).to eq([1,"Blablabla"])
    end
  end

  context "#find_ingredient_qty_without_unit" do
    it ("should call string_to_number if input does match with checking regrex") do 
      expect(RecipeFetch).to receive(:string_to_number).with("1 1/2").and_return(1.5)
      RecipeFetch.find_ingredient_qty_without_unit("1 1/2 Blablabla")
    end

    it ("should return qty = 1 and ingredient = input if the input does not match with checking regrex") do 
      expect(RecipeFetch.find_ingredient_qty_without_unit("Blablabla")).to eq([ 1, "Blablabla" ])
    end

    it ("should return qty = 1 and ingredient = input if the input is nil") do 
      expect(RecipeFetch.find_ingredient_qty_without_unit(nil)).to eq([ 1, nil ])
    end
  end

  context "#string_to_number" do
    it ("should call fractional_to_number with qta if qta contain /") do
      expect(RecipeFetch).to receive(:fractional_to_number).with("1/2").and_return(0.5)
      RecipeFetch.string_to_number("1/2")
    end

    it ("should return 0.5 if I pass 1/2") do
      allow(RecipeFetch).to receive(:fractional_to_number).with("1/2").and_return(0.5)
      expect(RecipeFetch.string_to_number("1/2")).to be(0.5)
    end

    it ("should return 4 if I pass '4'") do
      expect(RecipeFetch.string_to_number("4")).to be(4.0)
    end

    it ("should return 1 if I pass 'bla'") do
      expect(RecipeFetch.string_to_number("bla")).to be(1.0)
    end

    it ("should return 1 if I pass ' '") do
      expect(RecipeFetch.string_to_number(" ")).to be(1.0)
    end

    it ("should return 1 if I pass ''") do
      expect(RecipeFetch.string_to_number("")).to be(1.0)
    end

  end

  context "#fractional_to_number" do 
    it ("should return 4 if I pass '4' ") do
      expect(RecipeFetch.fractional_to_number("4")).to eq(4)
    end

    it ("should return 0.5 if I pass '1/2' ") do
      expect(RecipeFetch.fractional_to_number("1/2")).to eq(0.5)
    end

    it ("should return 1 if I pass 'bla' ") do
      expect(RecipeFetch.fractional_to_number("bla")).to eq(1)
    end

    it ("should return 1.5 if I pass '1 1/2' ") do
      expect(RecipeFetch.fractional_to_number('1 1/2')).to eq(1.5)
    end
  end
end