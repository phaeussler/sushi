require 'json'
require 'net/sftp'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  protect_from_forgery unless: -> { request.format.json? }
  helper_method :grup_request
  include HTTParty
  @@server = "dev"
  @@recepcion = @@server != "dev" ? "5cc7b139a823b10004d8e6cd" : "5cbd3ce444f67600049431b3"
  @@despacho = @@server != "dev" ? "5cc7b139a823b10004d8e6ce" : "5cbd3ce444f67600049431b4"
  @@pulmon = @@server != "dev" ? "5cc7b139a823b10004d8e6d1" : "5cbd3ce444f67600049431b7"
  @@cocina = @@server != "dev" ? "5cc7b139a823b10004d8e6d2" : "5cbd3ce444f67600049431b8"


  @@api_key = "RAPrFLl620Cg$o"
  @@ordenes_pendientes = []
  @@first_execution = false
  @@using_despacho = false

    '''Ultima conexión al servidor SFTP'''
    @@last_time = Time.now
    '''Consulta al servidor SFTP las ordenes nuevas y las retorna'''


  @@id_oc_prod = "5cc66e378820160004a4c3bc"
  @@id_oc_dev = "5cbd31b7c445af0004739be3"
  @@ftp_user = "grupo1_dev"
  @@ftp_password = "9me9BCjgkJ8b5MV"
  @@ftp_url = "fierro.ing.puc.cl"
  @@ftp_port = "22"

  def get_request(g_num, uri)
    begin  # "try" block
      base_url = "http://tuerca#{g_num}.ing.puc.cl"
      # uri : str orders or inventories ....
      response = HTTParty.get("#{base_url}/#{uri}")
      return response.code, response.body
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      puts "Error del otro grupo #{e}"
      return 500, {}, {}
    end
  end

  def order_request(g_num, sku, storeId, quantity, id)
    # g_num : int [1..14]
    # # uri = "orders?sku=#{sku}&almacenId=#{storeId}&cantidad=#{quantity}"
    # if id
    #   body_dict = {sku: sku, almacenId: storeId, cantidad:quantity}.to_json
    # else
    body_dict = {sku: sku, almacenId: storeId, cantidad:quantity, oc: id}.to_json
    puts "order_request #{body_dict}"
    # end
    request_group("orders", g_num, body_dict)
  end

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
        body: body_dict, timeout: 30)
      # puts "Solicitud: #{resp.code}"
      # puts JSON.parse(resp.body)
      # puts "Header #{resp.headers}"
      return resp.code, resp.body, resp.headers
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      puts "Error del otro grupo #{e}"
      return 500, {}, {}
    end
  end

  def request_oc(uri, body)
    base_url ="https://integracion-2019-#{@@server}.herokuapp.com/"
    puts "request oc #{base_url+uri} body #{body.to_json}"
    request = HTTParty.put(base_url+uri,
		  body:body.to_json,
		  headers:{
		    "Content-Type": "application/json"
      })
    puts request.code, request.headers, request.body
    return request
    end

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
    base_url ="https://integracion-2019-#{@@server}.herokuapp.com/bodega/"
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
    request = HTTParty.post("https://integracion-2019-#{@@server}.herokuapp.com/bodega/moveStock",
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

  def move_product_bodega(product_id, almacen_id, oc, precio)
    oc_id = oc["_id"]
    hash_str = hash("POST#{product_id}#{almacen_id}", @@api_key)
    request = HTTParty.post("https://integracion-2019-#{@@server}.herokuapp.com/bodega/moveStockBodega",
		  body:{
				"productoId": product_id,
				"almacenId": almacen_id,
        "oc": oc_id,
        "precio": precio,
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo1:#{hash_str}",
		    "Content-Type": "application/json"
		  })
    puts "\nDespacho de #{product_id} a otro grupo\n"
    puts JSON.parse(request.body)
    return request
  end

  def fabricarSinPago(api_key, sku, cantidad)
    hash_str = hash("PUT#{sku}#{cantidad}", api_key)
    producido = HTTParty.put("https://integracion-2019-#{@@server}.herokuapp.com/bodega/fabrica/fabricarSinPago",

		  body:{
		  	"sku": sku,
		  	"cantidad": cantidad
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo1:#{hash_str}",
		    "Content-Type": "application/json"
		  })
      puts "\n____________ENVIO A FABRICAR_________ #{sku} #{cantidad}\n"
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
        begin
            move_product_almacen(lista_productos[i]["_id"], almacenId_destino)
        rescue NoMethodError => e
        end
      end
    end

    #Mueva una cantidad determinada a la bodega de de un grupo


  def move_q_products_bodega(almacenId_actual, almacenId_destino, sku, cantidad, oc)
     '''1. Lista con los productos que tengo con el sku pedido'''
      lista_productos = request_product(almacenId_actual, sku, @@api_key)[0]
      cantidad = cantidad.to_i
      for i in 0..cantidad -1 do
        move_product_bodega(lista_productos[i]["_id"], almacenId_destino, oc, 1)
      end
    end

  '''Invetario de cocina + pulmón'''
  def get_inventories
    puts "CONSULTANDO INVENTARIO COCINA + PULMON\n"
    recepcion = sku_with_stock(@@cocina,@@api_key)[0]
    pulmon = sku_with_stock(@@pulmon,@@api_key)[0]
    productos = recepcion + pulmon
    # productos.group_by(&:capitalize).map {|k,v| [k, v.length]}
    productos = productos.group_by{|x| x["_id"]}
    respuesta = []
    for sku, dic in productos do
      total = 0
      nombre = Product.find_by sku: sku.to_i
      for y in dic do
        total += y["total"]
      end
      begin
        res = {"sku": sku,"nombre": nombre["name"], "total": total}
        respuesta << res
      rescue NoMethodError => e
      end
    end
    respuesta
  end

  '''Invetario de cocina + pulmón en forma de diccionario {id:total}'''
  def get_dict_inventories
    puts "get_dict_inventories\n"
    recepcion = get_inventorie_from_cellar('recepcion')
    pulmon = get_inventorie_from_cellar('pulmon')
    inventories = recepcion
    for sku, total in pulmon do
      in_reception = inventories[sku] ? inventories[sku] : 0
      inventories[sku] = total+ in_reception
    end
    puts "get_dict_inventories -> #{inventories}"
    return inventories
  end

  '''Se le da como parametro el nombre de la bodega a analizar y te entrega un diccionario con {id:total} de la bodega'''
  def get_inventorie_from_cellar(name)
    puts "get_inventorie_from_cellar"
    if name == "recepcion"
      # puts "RECECPCION"
      cellar = sku_with_stock(@@recepcion, @@api_key)[0]
    elsif name == "cocina"
      # puts "COCINA"
      cellar = sku_with_stock(@@cocina, @@api_key)[0]
    elsif name == "pulmon"
      # puts "PULMON"
      cellar = sku_with_stock(@@pulmon, @@api_key)[0]
    elsif name == "despacho"
      # puts "DESPACHO"
      cellar = sku_with_stock(@@despacho, @@api_key)[0]
    else
      puts "Error nombre de bodega mal ingresado #{name}"
    end
    dic = {}
    for item in cellar
      dic[item["_id"].to_i] = item["total"]
    end
    puts "#{name} -> #{dic}"
    return dic
  end

  '''Invetario de cocina + pulmón de los productos que produzco'''
  def avaible_to_sell
    puts "CONSULTANDO INVENTARIO COCINA + PULMON\n"
    recepcion = sku_with_stock(@@cocina,@@api_key)[0]
    pulmon = sku_with_stock(@@pulmon,@@api_key)[0]
    productos = recepcion + pulmon
    # productos.group_by(&:capitalize).map {|k,v| [k, v.length]}
    productos = productos.group_by{|x| x["_id"]}
    respuesta = []
    for sku, dic in productos do
      puts "sku #{sku.to_i} #{sku.class.name}"
      total = 0
      product = Product.find_by sku: sku.to_i
      if product["groups"].split(",")[0] == "1"
        for y in dic do
          total += y["total"]
        end
        total -= 50
        if total > 0
          begin
            res = {"sku": sku,"nombre": product["name"], "total": total}
            respuesta << res
          rescue NoMethodError => e
          end
        end
      end
    end
    respuesta
  end

  def preparar_despacho(orden)
      restante = orden["cantidad"].to_i
      cant_pulmon = sku_with_stock(@@pulmon)
      suma = 0
      for i in cant_pulmon
        if i["_id"].to_s == orden["sku"].to_s
          suma = i["total"].to_i
        end
      end
      if suma >= orden["cantidad"].to_i
        move_q_products_almacen(@@pulmon,@@despacho, orden["sku"], orden["cantidad"].to_i)
      else
        move_q_products_almacen(@@pulmon,@@despacho,orden["sku"],  suma)
        restante -= suma
        move_q_products_almacen(@@cocina,@@despacho, orden["sku"],  restante)
      end
  end

  def despachar_ftp(orden)
    '''Ojo que para hacerlo mas rapido muevo de a un producto'''
    cantidad = orden["cantidad"].to_i
    dir = "hola12345"
    precio = orden["precioUnitario"].to_i
    for i in 0..cantidad -1 do
        move_q_products_almacen(@@pulmon,@@despacho, orden["sku"], 1)
        lista_productos = request_product(@@despacho, orden["sku"], @@api_key)[0]
        despachar_producto(lista_productos[i]["_id"], orden["_id"], dir, precio)
    end
    '''1. Muevo los productos de pulmon a despacho'''
    #preparar_despacho(orden)
    # lista_productos = request_product(@@despacho, orden["sku"], @@api_key)[0]
    # cantidad = orden["cantidad"].to_i
    # dir = "hola12345"
    # precio = orden["cantidad"].to_i * orden["precioUnitario"].to_i
    # '''2. Por cada uno de esos productos, lo despacho'''
    # for i in 0..cantidad -1 do
    #       despachar_producto(lista_productos[i]["_id"], orden["_id"], dir, precio)
    # end
    '''3. Elimino la orden de compra de pendientes'''
    @@ordenes_pendientes.delete(orden)
  end

  def despachar_producto(product_id, orden_id, dir, precio)
    hash_str = hash("DELETE#{product_id}#{dir}#{precio}#{orden_id}", @@api_key)
    request = HTTParty.delete("https://integracion-2019-prod.herokuapp.com/bodega/stock",
      body:{
        "productoId": product_id,
        "oc": orden_id,
        "direccion": dir,
        "precio": precio }.to_json,

      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_str}",
        "Content-Type": "application/json"
          })
      puts "\nDespachar producto\n"
    puts JSON.parse(request.body)
    return request
  end

  '''Enviar a fabricar productos finales, '''
  def fabricar_producto_API(id, sku, cantidad)
    hash_str = hash("PUT#{sku}#{cantidad}#{id}", @@api_key)
    producido = products_produced = HTTParty.put("https://integracion-2019-prod.herokuapp.com/bodega/fabrica/fabricar",
      body:{
        "sku": sku,
        "cantidad": cantidad
      }.to_json,
      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_str}",
        "Content-Type": "application/json"
      })
      puts "\nENVIO A FABRICAR PRODUCTO FINAL\n"
      puts JSON.parse(producido.body)
    return producido
  end

  def get_ftp
    puts "GET FTP"
    @host = "fierro.ing.puc.cl"
    @grupo = "grupo1"
    @grupo2 = "grupo1_dev"
    @password = "p7T4uNY3yqdDB8sS3"
    @password2 = "9me9BCjgkJ8b5MV"
    contador = 0
    Net::SFTP.start(@host, @grupo2, :password => @password2) do |sftp|
      @ordenes = []
      sftp.dir.foreach("pedidos") do |entry|
        @now = Time.now
        if (Time.at(entry.attributes.mtime) > @@last_time)
          puts "GET FTP ENTRE"
          puts "TIME #{Time.at(entry.attributes.mtime)}"
          if entry.name .include? ".xml"
            data = sftp.download!("pedidos/#{entry.name}")
            json = Hash.from_xml(data).to_json
            json = JSON.parse json
            ''' agregor cada orden como un diccionarioa una lista'''
            id = json["order"]["id"]
            puts "ID #{id}"
            orden = obtener_oc(id)[0]
            puts "ORDEN #{orden}\n"
            @ordenes << orden
          end
        end
      end
      @@last_time = Time.now
      return @ordenes
    end
  end

  def obtener_oc(id)
    puts "Obtener OC"
    url ="https://integracion-2019-#{@@server}.herokuapp.com/oc/obtener/#{id}"
    response = HTTParty.get(url,
    headers:{
	    "Content-Type": "application/json"})
    return JSON.parse(response.body)
  end

  def recepcionar_oc(orden_id)
      url ="https://integracion-2019-#{@@server}.herokuapp.com/oc/recepcionar/#{orden_id}"
      response = HTTParty.post(url,
        body:{
		  	"id": orden_id,
		  }.to_json,
        headers:{
  		    "Content-Type": "application/json"})
        puts JSON.parse(response.body)
        return JSON.parse(response.body), response.headers
  end

  def rechazar_oc(orden_id)
    motivo = "Porque si"
    url ="https://integracion-2019-#{@@server}.herokuapp.com/oc/rechazar/#{orden_id}"
    response = HTTParty.post(url, body:{
        "id": orden_id,
        "rechazo": motivo,}.to_json,
         headers:{
      		"Content-Type": "application/json"
        })
        puts "\nRechazar OC\n"
        puts JSON.parse(response.body)
    return JSON.parse(response.body), response.headers
  end



  """crea una fecha en el futuro 4 hrs por ahora"""
  def create_deliver_date(sku)
    product = Product.find_by sku: sku
    groups = product.groups
    groups = product.groups.split(",")
    return ((Time.now.to_f + 100000) * 1000).to_i
    # if groups.include?("1")
    #   return ((Time.now.to_f + product.expected_time_production_mins/2)*1000).to_i
    # else
    #   return (Time.now.to_f*1000 + (product.expected_time_production_mins*1.2)*1000).to_i
    # end

  end

  """busca el id de oc de cada grupo"""
  def find_oc_group(n_group)
    puts "find_oc_group"
    group = GroupIdOc.find_by group: n_group.to_s
    return @@server == "dev" ? group.id_development : group.id_production
  end

  '''Crea una oc al servidor'''
  def create_oc(sku, qty, group)
    # Primero debo buscar el id del grupo
    puts "CREAR ORDER"
    group = "5cc66e378820160004a4c3c9"
    product = Product.find_by sku: sku
    cliente = @@server == "dev" ? @@id_oc_dev : @@id_oc_prod
    price = product.sell_price ? product.sell_price : 1
    order = {
      "cliente": cliente,
      "proveedor": find_oc_group(group),
      # "cliente": @@id_oc_prod,
      # "proveedor": @@id_oc_dev,
      "sku": sku,
      "fechaEntrega": create_deliver_date(sku) ,
      "cantidad": qty.to_s,
      "precioUnitario": price,
      "canal": "b2b",
      "notas": "Please",
      "urlNotificacion": "http://tuerca1.ing.puc.cl/orders/{_id}/notification"
    }
    return request_oc('oc/crear', order)
  end

  def despachar_http(sku, cantidad, almacenId, orden)
    '''1. Mover del sku pedido, la cantidad pedida, de pulmon a despacho'''
    move_q_products_almacen(@@pulmon, @@despacho, sku, cantidad)
    '''3. Despachar a los otros grupos'
    move_q_products_bodega(@@despacho, almacenId, sku, cantidad, orden)
  end

  def obtener_hook
    uri = "hook"
    hash_str = "GET"
    return request_system(uri, hash_str, @@api_key)
  end

  def setear_hook
    url = "http://tuerca1.ing.puc.cl/ftporders"
    hash_str = hash("PUT#{url}", @@api_key)
    request = HTTParty.put("https://integracion-2019-#{@@server}.herokuapp.com/bodega/hook",
    body:{
      "url": url,
    }.to_json,
    headers:{
      "Authorization": "INTEGRACION grupo1:#{hash_str}",
      "Content-Type": "application/json"
    })
    puts "\nSetear Hook\n"
    puts request.code
  end

  def create_deliver_date(sku)
    product = Product.find_by sku: sku
    groups = product.groups
    groups = product.groups.split(",")
    return ((Time.now.to_f + 100000) * 1000).to_i
    # if groups.include?("1")
    #   return ((Time.now.to_f + product.expected_time_production_mins/2)*1000).to_i
    # else
    #   return (Time.now.to_f*1000 + (product.expected_time_production_mins*1.2)*1000).to_i
    # end

  end

  def find_oc_group(n_group)
    puts "find_oc_group"
    group = GroupIdOc.find_by group: n_group.to_s
    if @@server == "dev"
      return group.id_development
    else
      return group.id_production
    end
  end

  def recepcion_a_pulmon(productos)
      for i in sku_with_stock(@@recepcion, @@api_key)[0]
        lista_productos = request_product(@@recepcion, i["_id"], @@api_key)[0]
        for j in lista_productos do
          move_product_almacen(j["_id"], @@despacho)
          move_product_almacen(j["_id"], @@pulmon)
        end
      end
    end

  def cocina_a_pulmon
    for i in sku_with_stock(@@cocina, @@api_key)[0]
      lista_productos = request_product(@@cocina, i["_id"], @@api_key)[0]
      for j in lista_productos do
        move_product_almacen(j["_id"], @@despacho)
        move_product_almacen(j["_id"], @@pulmon)
      end
    end
  end

  def despacho_a_pulmon
    for i in sku_with_stock(@@despacho, @@api_key)[0]
      lista_productos = request_product(@@despacho, i["_id"], @@api_key)[0]
      for j in lista_productos do
        move_product_almacen(j["_id"], @@pulmon)
      end
    end
  end

  def pendientes
    '''1. Para asegurarnos, eliminar las ordenes que estan completas y actualizar las ordenes'''
    new_orders = []
    for i in @@ordenes_pendientes
      orden = obtener_oc(i["_id"])[0]
      if orden["estado"] != "aceptada"
        @@ordenes_pendientes.delete(i)
      else
        new_orders << orden
      end
    end
    @@ordenes_pendientes = new_orders

    '''2. Si tengo el sku, y la cantidad en el inventario, despacharlo'''
    '''Hay que hacer un get_inventories de cocina nom+as OJO'''
    stock = get_inventories
    if stock.length > 0 and @@ordenes_pendientes.length > 0
      for s in stock
        for i in 0..@@ordenes_pendientes.length
          if s[:sku].to_i == @@ordenes_pendientes[i]["sku"].to_i
            if s[:total].to_i >= @@ordenes_pendientes[i]["cantidad"].to_i
              @@using_despacho = true
              despachar_ftp(orden)
              @@using_despacho = false
            end
          end
        end
      end
    end
  end

end
