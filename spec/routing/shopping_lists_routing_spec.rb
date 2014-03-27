require "spec_helper"

describe ShoppingListsController do
  describe "routing" do

    it "routes to #index" do
      get("/shopping_lists").should route_to("shopping_lists#index")
    end

    it "routes to #new" do
      get("/shopping_lists/new").should route_to("shopping_lists#new")
    end

    it "routes to #show" do
      get("/shopping_lists/1").should route_to("shopping_lists#show", :id => "1")
    end

    it "routes to #edit" do
      get("/shopping_lists/1/edit").should route_to("shopping_lists#edit", :id => "1")
    end

    it "routes to #create" do
      post("/shopping_lists").should route_to("shopping_lists#create")
    end

    it "routes to #update" do
      put("/shopping_lists/1").should route_to("shopping_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/shopping_lists/1").should route_to("shopping_lists#destroy", :id => "1")
    end

  end
end
