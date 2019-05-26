class Ftp < ApplicationController
  require 'net/ftp'


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

  '''Parsear la orden'''
  def parse_orden(orden)
    orden_final = {}
    '''1. Obtener Id'''
    id = orden.split("<id>")
    orden_final["id"] = id.split("</id>")[0]
    '''2. Obtener sku '''
    sku = orden.split("<sku>")[1]
    orden_final["sku"] = sku.split("</sku>")[0]
    '''3. Obtener cantidad '''
    cantidad = orden.split("<qty>")[1]
    orden_final["cantidad"] = cantidad.split("</qty>")[0].to_i
    return orden_final
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



end
