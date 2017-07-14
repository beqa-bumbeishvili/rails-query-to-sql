Rails.application.routes.draw do
  get 'main/index'
  get 'main/convert'
  root 'main#convert'
end
