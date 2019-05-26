class Ftp < ApplicationController
  require 'json'
  require 'net/sftp'

  def execute
    '''Esto es temporal, deberia ser la orden que me llega'''
    ordenes = ftp_orders("1")
    orden = parse_orden(ordenes[1])
    '''Esto sí va'''
    evaluacion = evaluar_orden_de_compra(orden)
    notificar_orden(orden, evaluacion)
    if evaluacion
      despachar_producto(orden)
    end
  end


  '''Reviso la orden segun su Id'''
  def ftp_orders(id)
    '''1. Me llega un POST con el id de la orden'''
    '''2. Conectarse con servidor ftp y revisar las ordenes y encontrar aquella con el Id'''
    '''3. Borrar la orden del servidor ftp para no volver a analizarla'''
    '''4. Retornar la orden para luego analizarla'''

    '''Esto es temporal'''
    ordenes =  Dir.entries("pedidos")
    oc = []
    for orden in ordenes
      begin
        archivo = File.read("pedidos/#{orden}").split
        oc << archivo[3]
      rescue Errno::EISDIR => e
      end
    end
    return oc
  end

  def evaluar_orden_de_compra(orden)
    sku = orden["sku"]
    cantidad = orden["cantidad"]
    '''1. Consultar inventario '''
    inventario = get_inventories
    stock = 0
    for producto in inventario
      if producto[:sku] == sku
        stock = producto[:total].to_i
      end
    end
    '''2. Acepto o Rechazo'''
    '''Ojo que acá se puede hacer algo más avanzado como revisar si tengo los ingredientes para fabricar y mandar a fabricar'''
    if stock - cantidad > 0
      return true
    else
      return false
    end
  end


  '''Ultima conexión al servidor SFTP'''
  @@last_time = Time.now
  '''Consulta al servidor SFTP las ordenes nuevas y las retorna'''



  def get_ftp()
    ''' !!!!CAMBIAR A PRODUCCIÓN
  Ambiente: PRODUCCIÓN
  Usuario: grupo1
  Clave: p7T4uNY3yqdDB8sS3
  URL Servidor: fierro.ing.puc.cl
  Puerto: 22 '''
  @host = "fierro.ing.puc.cl"
  @grupo = "grupo1_dev"
  @password = "9me9BCjgkJ8b5MV"
  contador = 0

  puts @@last_time

  Net::SFTP.start(@host, @grupo, :password => @password) do |sftp|
    @ordenes = []
    sftp.dir.foreach("pedidos") do |entry|
    contador +=1
    if contador > 2
      if (Time.at(entry.attributes.mtime) > @@last_time)
        orden =  {}
        data = sftp.download!("pedidos/#{entry.name}")
        json = Hash.from_xml(data).to_json
        json = JSON.parse json
        ''' agregor cada orden como un diccionarioa una lista'''
        orden["id"] = json["order"]["id"]
        orden["sku"] = json["order"]["sku"]
        orden["qty"] = json["order"]["qty"]
        @ordenes << orden
      end
      contador += 1
    end
    end
    # ejemplo de retorno [{"id"=>"5ce54a70ff732f000426a96f", "sku"=>"10005", "qty"=>"3"}]
    puts @ordenes
    @@last_time = Time.now
    return @ordenes
    end
  end



end
