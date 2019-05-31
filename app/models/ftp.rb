class Ftp < CheckController
  require 'json'
  require 'net/sftp'

  def execute
    '''1. Veo las ordenes que me llegan '''
    ordenes = get_ftp
    puts "ORDENES"
    for orden in ordenes
      evaluacion = false
      if orden["canal"] == "b2b"
        '''NO hago nada'''
      else
        sku = orden["sku"]
        cantidad = orden["cantidad"]
        '''2. Por casa orden, evaluo si puedo producir el producto'''
        evaluacion = evaluar_fabricar_final(cantidad, sku)
        if evaluacion
          '''Notificar aceptacion'''
          '''3. Mando a fabricar el producto, si es que la evaluacion es positiva'''
          respuesta = fabricar_final(cantidad, sku)
          '''3.1 Si hay un error en la fabricación'''
          if respuesta["error"]
            rechazar_oc(orden["_id"])
          '''3.2 Si va todo bien en la fabricacion'''
          else
            '''3.2.1 Recepciono la orden'''
            recepcionar_oc(orden["_id"])
            '''3.2.2 Agrego la orden a pendientes'''
            @@ordenes_pendientes << orden
          end
        '''4. Si la evaluacion es negativa, rechazo la orden'''
        else
          '''Notificar rechazo'''
          rechazar_oc(orden["_id"])
        end
      end
    end
  end




end
