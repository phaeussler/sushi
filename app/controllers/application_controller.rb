require 'json'

class ApplicationController < ActionController::Base

  # protect_from_forgery with: :exception
  protect_from_forgery unless: -> { request.format.json? }
  helper_method :grup_request
  include HTTParty
  
  @@recepcion = "5cbd3ce444f67600049431b3"
  @@despacho = "5cbd3ce444f67600049431b4"
  @@pulmon = "5cbd3ce444f67600049431b7"
  @@cocina = "5cbd3ce444f67600049431b8"
  @@api_key = "RAPrFLl620Cg$o"
  
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



  def hash(data, secret_key)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_key.encode("ASCII"), data.encode("ASCII"))
    signature = Base64.encode64(hmac).chomp
    return signature
  end

  def request_system(uri,method_str, api_key)
    hash_str = hash(method_str, api_key)
    base_url ="https://integracion-2019-dev.herokuapp.com/bodega/"
    resp = HTTParty.get("#{base_url}#{uri}",
      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_str}",
        "Content-Type": "application/json"
      })
    puts "Solicitud: #{resp.code}"
    puts JSON.parse(resp.body)
    return resp
  end


  def request_product(id, sku, api_key)
    uri = "stock?almacenId=#{id}&sku=#{sku}"
    hash_str = "GET#{id}#{sku}"
    return request_system(uri, hash_str, api_key)
  end

  def sku_with_stock(id, api_key)
    uri = "skusWithStock?almacenId=#{id}"
    hash_str = "GET#{id}"
    return request_system(uri, hash_str,api_key)
  end

  #almacen_id es id de destino.
  def move_product_almacen(product_id, almacen_id)
    hash_str = hash("POST#{product_id}#{almacen_id}", @@api_key)
    request = HTTParty.post("https://integracion-2019-dev.herokuapp.com/bodega/moveStock",
		  body:{
				"productoId": product_id,
				"almacenId": almacen_id,

		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo1:#{hash_str}",
		    "Content-Type": "application/json"
		  })
      puts "\nMOVER ALMACEN\n"
      puts JSON.parse(request.body)
      return request
  end

  def move_product_bodega(product_id, almacen_id)
    hash_str = hash("POST#{product_id}#{almacen_id}", @@api_key)
    request = HTTParty.post("https://integracion-2019-dev.herokuapp.com/bodega/moveStockBodega",
		  body:{
				"productoId": product_id,
				"almacenId": almacen_id,
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo1:#{hash_str}",
		    "Content-Type": "application/json"
		  })
      puts "\nMOVER BODEGA\n"
      puts JSON.parse(request.body)
      return request
  end

  def fabricarSinPago(api_key, sku, cantidad)
    hash_str = hash("PUT#{sku}#{cantidad}", api_key)
    producido = products_produced = HTTParty.put("https://integracion-2019-dev.herokuapp.com/bodega/fabrica/fabricarSinPago",
		  body:{
		  	"sku": sku,
		  	"cantidad": cantidad
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo1:#{hash_str}",
		    "Content-Type": "application/json"
		  })
      puts "\nENVIO A FABRICAR\n"
		  puts JSON.parse(producido.body)

      return producido
    end
end
