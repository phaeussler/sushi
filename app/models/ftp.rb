class Ftp < ApplicationController
  require 'json'
  require 'net/sftp'

  def execute
    '''Esto es temporal, deberia ser la orden que me llega'''
    ordenes = get_ftp
    evaluacion = false
    orden = ordenes[0]
    for orden in ordenes
      if orden["canal"]
        if orden["canal"] == "b2b"
          '''NO hago nada'''
        else
          evaluacion = evaluar_orden_de_compra(orden)
        end
      else
        evaluacion = evaluar_orden_de_compra(orden)
      end
      if evaluacion
        puts "DEPACHANDO"
        despachar_producto(orden)
      end
    end
  end


  '''Reviso la orden segun su Id'''
  def ftp_order(id)
    '''1. Me llega un POST con el id de la orden'''
    '''2. Conectarse con servidor ftp y revisar las ordenes y encontrar aquella con el Id'''
    '''3. Borrar la orden del servidor ftp para no volver a analizarla'''
    '''4. Retornar la orden para luego analizarla'''
  end

  def evaluar_orden_de_compra(orden)
    puts "Evaluando Orden"
    sku = orden["sku"]
    cantidad = orden["qty"].to_i
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
