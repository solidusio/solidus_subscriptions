# frozen_string_literal: true

SolidusSubscriptions::Engine.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :line_items, only: [:update, :destroy]
      resources :subscriptions, only: [:create, :update] do
        member do
          post :cancel
          post :skip
          post :pause
          post :resume
        end
      end
    end
  end
end

Spree::Core::Engine.routes.draw do
  mount SolidusSubscriptions::Engine, at: '/subscriptions'

  namespace :admin do
    resources :subscriptions, only: [:index, :new, :create, :edit, :update] do
      member do
        delete :cancel
        post :activate
        post :skip
        post :pause
        post :resume
      end
      resources :installments, only: [:index, :show]
      resources :subscription_events, only: :index
      resources :subscription_orders, path: :orders, only: :index
    end

    resources :users do
      resources :subscriptions, only: [:index], controller: 'users/subscriptions'
    end
  end
end
