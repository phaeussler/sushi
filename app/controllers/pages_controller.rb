class PagesController < ApplicationController
  def home
    handler = Handler.new
    handler.empty_reception
  end
end
