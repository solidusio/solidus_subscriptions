SolidusSubscriptions::Engine.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :line_items, only: [:update, :destroy]
      resources :subscriptions, only: [:update, :create] do
        member do
          post :cancel
          post :skip
        end
      end
    end
  end
end

Spree::Core::Engine.routes.draw do
  mount SolidusSubscriptions::Engine, at: '/subscriptions'

  namespace :admin do
    resources :subscriptions, only: [:index, :new, :create, :edit, :update] do
      delete :cancel, on: :member
      post :activate, on: :member
      post :skip, on: :member
    end
  end
end
