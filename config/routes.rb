Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/get_headers", to: "netcents_express_checkout#get_headers"
  get "/get_cart_items", to: "netcents_express_checkout#get_cart_items"
  get "/oauth/authorize", to: "netcents_express_checkout#confirm"
end
