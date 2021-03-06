Rails.application.routes.draw do

  root 'welcome#index'
  get 'contacts' => 'welcome#contacts'
  get "scene/:id/download/:filename" => "scene#download", :as => :download_from_scene, filename: /[^\/]+/
  get "scene/:id/show/:filename" => "scene#show", :as => :show_from_scene, filename: /[^\/]+/

  resources :tasks, only: [:new, :create, :show] do
    get 'perform', :on => :member
    post 'show', :on => :collection, as: :search
  end

  get 'macroape/description' => 'welcome#macroape', as: :macroape_description
  get 'macroape' => 'welcome#macroape'

  get 'perfectosape/description' => 'welcome#perfectosape', as: :perfectosape_description
  get 'perfectosape' => 'welcome#perfectosape'

  get 'chipmunk/description' => 'welcome#chipmunk', as: :chipmunk_description
  get 'chipmunk' => 'welcome#chipmunk'

  namespace :macroape do
    get 'scan' => 'scans#new'
    resources :scans, only: [:new, :create, :show], path: 'scan' do
      get 'perform', :on => :member
      get 'description', :on => :collection
    end

    get 'compare' => 'compares#new'
    resources :compares, only: [:new, :create, :show], path: 'compare' do
      get 'perform', :on => :member
      get 'description', :on => :collection
    end
  end

  namespace :perfectosape do
    get 'scan' => 'scans#new'
    resources :scans, only: [:new, :create, :show], path: 'scan' do
      get 'perform', :on => :member
      get 'description', :on => :collection
    end
  end

  namespace :chipmunk do
    namespace :discovery do
      get '/' => 'mono#new'
      get 'mono' => 'mono#new'
      resources :mono, only: [:new, :create, :show], path: 'mono' do
        get 'perform', :on => :member
        get 'description', :on => :collection
      end

      get 'di' => 'di#new'
      resources :di, only: [:new, :create, :show], path: 'di' do
        get 'perform', :on => :member
        get 'description', :on => :collection
      end
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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
