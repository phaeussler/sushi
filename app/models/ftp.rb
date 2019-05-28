class Ftp < ApplicationController
  require 'json'
  require 'net/sftp'

  def execute
    '''Esto es temporal, deberia ser la orden que me llega'''
    ordenes = get_ftp
    puts "ORDENES"
    for orden in ordenes
      evaluacion = false
      if orden["canal"] == "b2b"
        '''NO hago nada'''
      else
        evaluacion = evaluar_orden_de_compra(orden)
        if evaluacion
          '''Notificar aceptacion'''
          recepcionar_oc(orden)
          despachar_productos_sku(orden)
        else
          '''Notificar rechazo'''
          rechazar_oc(orden)
        end
      end
    end
  end


  def evaluar_orden_de_compra(orden)
    '''Aqui hay que hacer el GET OC'''
    puts "Evaluando Orden"
    sku = orden["sku"]
    cantidad = orden["cantidad"].to_i
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
