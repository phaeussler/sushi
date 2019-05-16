require 'json'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  protect_from_forgery unless: -> { request.format.json? }
  helper_method :grup_request
  include HTTParty

  @@recepcion = "5cc7b139a823b10004d8e6cd"
  @@despacho = "5cc7b139a823b10004d8e6ce"
  @@pulmon = "5cc7b139a823b10004d8e6d1"
  @@cocina = "5cc7b139a823b10004d8e6d2"
  @@lista_almacenes = [@@recepcion, @@despacho, @@pulmon, @@cocina]
  @@api_key = "RAPrFLl620Cg$o"

  def get_request(base_url, uri)
    # base_url : str ej "http://tuerca#{g_num}.ing.puc.cl/"
    # uri : str orders or inventories ....
    response = HTTParty.get("#{base_url}/#{uri}")
    return response.code, response.body
  end

  def order_request(g_num, sku, storeId, quantity)
        # g_num : int [1..14]
        # uri = "orders?sku=#{sku}&almacenId=#{storeId}&cantidad=#{quantity}"
        body_dict = {sku: sku, almacenId: storeId, cantidad:quantity}.to_json
        request_group("orders", g_num, body_dict)
    end

  # def post_request(base_url, uri)
  #       # base_url : str ej "http://tuerca#{g_num}.ing.puc.cl/"
  #       # uri : str orders or inventories ....
  #       begin  # "try" block
  #         puts "post_request #{base_url}/#{uri}"
  #         response = HTTParty.post("#{base_url}/#{uri}", timeout: 5)
  #         return response.code, response.body
  #       rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
  #         puts "Error del otro grupo #{e}"
  #         return 500, {}
  #       end
  #     end

  # def grup_request(method, g_num, uri)
  #   # g_num : int [1..14]
  #   # uri : str orders or inventories ...
  #   # orders?almacenId=1&sku=1211&cantidad=1
  #   base_url = "http://tuerca#{g_num}.ing.puc.cl"
  #   if method == "post"
  #     post_request(base_url, uri)
  #   else
  #     get_request(base_url,uri)
  #     "error"
  #   end
  # end

  #funcion que hace funcion post a los grupos
  def request_group(uri, g_num, body_dict)
    # hash_str = hash(method_str, api_key)
    base_url ="http://tuerca#{g_num}.ing.puc.cl/"
    begin  # "try" block
      puts "URL: #{base_url}#{uri}"
      resp = HTTParty.post("#{base_url}#{uri}",
        headers:{
          "group": "1",
          "Content-Type": "application/json"
        },
        body: body_dict, timeout: 15)
      # puts "Solicitud: #{resp.code}"
      # puts JSON.parse(resp.body)
      # puts "Header #{resp.headers}"
      return resp.code, resp.body, resp.headers
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      puts "Error del otro grupo #{e}"
      return 500, {}, {}
    end
  end

#FUNCIONES PARA INTERACTUAR CON EL SYSTEMA


  #funcion de hash
  def hash(data, secret_key)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_key.encode("ASCII"), data.encode("ASCII"))
    signature = Base64.encode64(hmac).chomp
    return signature
  end

  #funcion que hace funcion get al sistema
  def request_system(uri,method_str, api_key)
    hash_str = hash(method_str, api_key)
    base_url ="https://integracion-2019-prod.herokuapp.com/bodega/"
    resp = HTTParty.get("#{base_url}#{uri}",
      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_str}",
        "Content-Type": "application/json"
      })
    puts "Solicitud: #{resp.code}"
    puts JSON.parse(resp.body)
    puts "Header #{resp.headers}"
    return JSON.parse(resp.body), resp.headers
  end


  def request_product(id, sku, api_key)
    uri = "stock?almacenId=#{id}&sku=#{sku}"
    hash_str = "GET#{id}#{sku}"
    return request_system(uri, hash_str, api_key)
  end

  '''Productos con stock en el almacen pedido segun id.'''
  def sku_with_stock(id, api_key)
    uri = "skusWithStock?almacenId=#{id}"
    hash_str = "GET#{id}"
    puts "SKUS CON STOCK EN AMLACEN #{id}"
    return request_system(uri, hash_str,api_key)
  end

  #almacen_id es id de destino.
  def move_product_almacen(product_id, almacen_id)
    hash_str = hash("POST#{product_id}#{almacen_id}", @@api_key)
    request = HTTParty.post("https://integracion-2019-prod.herokuapp.com/bodega/moveStock",
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
    request = HTTParty.post("https://integracion-2019-prod.herokuapp.com/bodega/moveStockBodega",
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
    producido = products_produced = HTTParty.put("https://integracion-2019-prod.herokuapp.com/bodega/fabrica/fabricarSinPago",
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

   #Mueve todos los produsctos de un sku determinado
    def move_sku_almacen(almacenId_actual, almacenId_destino, sku)
          lista_productos = request_product(almacenId_actual, sku, @@api_key)[0]
          for j in lista_productos do
            move_product_almacen(j["_id"], almacenId_destino)
      end
    end
    #Mueve una cantidad determinada de un sku entre dos almacenes
    def move_q_products_almacen(almacenId_actual, almacenId_destino, sku, cantidad)
      lista_productos = request_product(almacenId_actual, sku, @@api_key)[0]
      cantidad = cantidad.to_i
      for i in 0..cantidad -1 do
            move_product_almacen(lista_productos[i]["_id"], almacenId_destino)
      end
    end

    #Mueva una cantidad determinada a la bodega de de un grupo
    def move_q_products_bodega(almacenId_actual, almacenId_destino, sku, cantidad)
      lista_productos = request_product(almacenId_actual, sku, @@api_key)[0]
      cantidad = cantidad.to_i
      for i in 0..cantidad -1 do
            move_product_bodega(lista_productos[i]["_id"], almacenId_destino)
      end
    end

  # arroja el inventario de recepcion + el pulmon con nombre incluido
  def get_inventories
    recepcion = sku_with_stock(@@recepcion,@@api_key)[0]
    pulmon = sku_with_stock(@@pulmon,@@api_key)[0]
    productos = recepcion + pulmon
    # productos.group_by(&:capitalize).map {|k,v| [k, v.length]}
    productos = productos.group_by{|x| x["_id"]}
    respuesta = []
    for p, dic in productos do
      total = 0
      nombre = Product.find_by sku: p
      for y in dic do
        total += y["total"]
      end
      res = {"sku": p,"nombre": nombre["name"], "total": total}
      puts "p #{p} -> total #{total}"
      respuesta << res
    end
    respuesta
  end





end
