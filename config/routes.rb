Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  root to: 'static_pages#home'
  devise_for :users
  resources :users

  resources :courses do
    member do
      post :rate
      get :bookmark
      get :publish
      get :review
    end
    get :autocomplete_tag_name, :on => :collection
    resources :course_modules do
      collection do
        get :reorder
        put :reorder_save
      end
    end
  end

  match "/images/uploads/*path" => "gridfs#serve"
end