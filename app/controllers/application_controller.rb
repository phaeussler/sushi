class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  protect_from_forgery unless: -> { request.format.json? }
  helper_method :grup_request
  include HTTParty
  
  def get_request(base_url, uri)
    # base_url : str ej "http://tuerca#{g_num}.ing.puc.cl/"
    # uri : str orders or inventories ....
    response = HTTParty.get("#{base_url}/#{uri}")
    return response.code, response.body
  end

  def post_request(base_url, uri)
    # base_url : str ej "http://tuerca#{g_num}.ing.puc.cl/"
    # uri : str orders or inventories ....
    response = HTTParty.post("#{base_url}/#{uri}")
    return response.code, response.body
  end

  def grup_request(method, g_num, uri)
    # g_num : int [1..14]
    # uri : str orders or inventories ...
    # orders?almacenId=1&sku=1211&cantidad=1
    base_url = "http://tuerca#{g_num}.ing.puc.cl/"
    if method == "post"
      post_request(base_url, uri)
    else
      get_request(base_url,uri)
      "error"
    end
  end
end
