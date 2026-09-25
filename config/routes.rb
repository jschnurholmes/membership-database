Rails.application.routes.draw do
  # Process-alive check for the ALB target group. Does not touch the database.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Deeper check for a CloudWatch alarm, not the ALB - also verifies the database.
  get 'up/db' => 'health#db'

  devise_for :users

  namespace :api do
    namespace :v1 do
      resources 'memberships', only: [] do
        collection do
          get 'index', to: 'memberships#index'
        end
        member do
          get 'show', to: 'memberships#show'
          get 'save', to: 'memberships#save'
        end
      end

      resources :members, only: [:index]
      get 'members', to: 'members#index'
    end
  end

  resources :memberships do
    member do
      post 'renew', to: 'memberships#renew'
    end
  end

  get 'people/member_list', to: 'people#member_list'
  get 'people/membership_cards', to: 'people#membership_cards'
  resources :people

  get 'reports',                     to: 'reports#index', as: :reports
  get 'reports/address_list',        to: 'reports#address_list', as: :reports_address_list
  get 'reports/email_list',          to: 'reports#email_list', as: :reports_email_list
  get 'reports/member_directory',    to: 'reports#member_directory', as: :reports_member_directory
  get 'reports/member_list',         to: 'reports#member_list', as: :reports_member_list
  get 'reports/membership_cards',    to: 'reports#membership_cards', as: :reports_membership_cards
  post 'reports/membership_cards',   to: 'reports#membership_cards'

  root 'memberships#index'

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
