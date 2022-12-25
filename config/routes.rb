Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :projects, only: %i[create update show]
    end
  end
end
