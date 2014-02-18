OperaWebface::Application.routes.draw do

  root 'welcome#index'
  get "scene/:id/download/:filename" => "scene#download", :as => :download_from_scene, filename: /[^\/]+/
  get "scene/:id/show/:filename" => "scene#show", :as => :show_from_scene, filename: /[^\/]+/

  resources :tasks, only: [:new, :create, :show] do
    get 'perform', :on => :member
    post 'show', :on => :collection, as: :search
  end

  get 'macroape' => 'welcome#macroape'
  get 'perfectosape' => 'welcome#perfectosape'
  namespace :macroape do
    get 'scan' => 'scans#new'
    resources :scans, only: [:new, :create, :show] do
      get 'perform', :on => :member
    end

    get 'compare' => 'compares#new'
    resources :compares, only: [:new, :create, :show] do
      get 'perform', :on => :member
    end
  end
  namespace :perfectosape do
    get 'scan' => 'scans#new'
    resources :scans, only: [:new, :create, :show] do
      get 'perform', :on => :member
    end
  end

  # get "tasks/new", :as => :new_task
  # post "tasks/create", :as => :tasks
  # get "tasks/:ticket/show" => "tasks#show", :as => :task
  # get "tasks/:ticket/status" => "tasks#status", :as => :task_status


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
