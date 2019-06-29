class ShoppingCartController < ApplicationController
    protect_from_forgery with: :exception

    include ShoppingCartHelper
end