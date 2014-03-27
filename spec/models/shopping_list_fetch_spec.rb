require 'spec_helper'

describe ShoppingListFetch do

let(:ingredient) {[{"ingredient"=>"i1","qta"=>6.0,"unit"=>"a","text"=>"bla"}]}
let(:ingredient_r) {[{"ingredient"=>"i1",'value'=>[{"unit"=>"a","qta"=>6.0}]}]}

let(:ingredient2) {[
                    {"ingredient"=>"name","qta"=>6.0,"unit"=>"a","text"=>"bla"},
                    {"ingredient"=>"name","qta"=>2.0,"unit"=>"a","text"=>"bla"}
                    ]}

let(:ingredient2_r) {[
                    {"ingredient"=>"name",'value'=>[{"unit"=>"a","qta"=>8.0}]}
                    ]}

let(:ingredient3) {[
                    {"ingredient"=>"name","qta"=>6.0,"unit"=>"a","text"=>"bla"},
                    {"ingredient"=>"ciao","qta"=>2.0,"unit"=>"a","text"=>"bla"}
                    ]}

let(:ingredient3_r) {[
                    {"ingredient"=>"name",'value'=>[{"unit"=>"a","qta"=>6.0}]},
                    {"ingredient"=>"ciao",'value'=>[{"unit"=>"a","qta"=>2.0}]}
                    ]}

let(:ingredient4) {[
                    {"ingredient"=>"name","qta"=>6.0,"unit"=>"a","text"=>"bla"},
                    {"ingredient"=>"name","qta"=>6.0,"unit"=>"a","text"=>"bla"},
                    {"ingredient"=>"name","qta"=>2.0,"unit"=>"b","text"=>"bla"}
                    ]}

let(:ingredient4_r) {[
                    {"ingredient"=>"name",'value'=>[{"unit"=>"a","qta"=>12.0},{"unit"=>"b","qta"=>2.0}]}
                    ]}

  context '#aggregate_ingredients' do  
    it 'return the ingredient if pass only one ingredient' do 
      expect(ShoppingListFetch.aggregate_ingredients(ingredient)).to eq(ingredient_r)
    end

    it 'return the ingredient with summed qty if pass 2 times same ingredient with same unit' do 
      expect(ShoppingListFetch.aggregate_ingredients(ingredient2)).to eq(ingredient2_r)
    end

    it 'return the ingredient without summed qty if pass 2 different ingredient with same unit' do 
      expect(ShoppingListFetch.aggregate_ingredients(ingredient3)).to eq(ingredient3_r)
    end

    it 'return the ingredient summing only the qty with the same unit' do 
      expect(ShoppingListFetch.aggregate_ingredients(ingredient4)).to eq(ingredient4_r)
    end
  end
end




# [{"ingredient"=>"i1","qta"=>6.0,"unit"=>"a","text"=>"bla"}]