Rails.application.routes.draw do
  # Incoming emails
  mount_griddler

  root 'index#index'
end
