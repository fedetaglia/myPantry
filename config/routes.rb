GetPantry::Application.routes.draw do
  
  devise_for :users 
  
  resources :shopping_lists

  resources :recipes do
    collection do
      get 'search'
      get 'search_detail'
    end
  end
  
  get 'getrecipe/:id' => 'recipes#getrecipe'

  get "index" => 'shopping_lists#index'
  # You can have the root of your site routed with "root"
  root to: "pages#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
end
