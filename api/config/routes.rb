# frozen_string_literal: true

Rails.application.routes.draw do
  resources :contacts do
    member do
      get :image
      post :upload
    end
  end
end
