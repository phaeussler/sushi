class FtpordersController < ApplicationController

  def index

  end

  '''Reviso si me llegaron ordenes'''
  def orders
    '''1. Me llega un POST con el id de la orden'''
    '''2. Conectarse con servidor ftp y revisar las ordenes'''
    '''3. Borrar la orden del servidor ftp para no volver a analizarla'''
    '''4. Retornar la orden para luego analizarla'''
  end

  '''Generar el Id de la orden de compra y retorna la OC completa'''
  def orden_de_compra
  end

  '''Notificar si se acepta o no una orden'''
  def notificar_orden
  end

  '''Fabrico producto a partir de una orden'''
  def fabricar_producto(id, sku, cantidad)
    '''PREV --> Revisar que tengo lo necesario para producir el producto final'''

    '''1. Llamar al metodo fabricar_producto_final'''
    '''2. Analizar respuesta de la API'''
    '''2.1 Si la respuesta es positiva'''
    '''2.1.1 Agregar el pedido a @@pedidos_pendientes'''
    '''2.1.2 Notificar al grupo comprador'''
    '''2.2 Si la respuesta es negativa'''
    '''2.2.1 Notificar al grupo comprador'''

  end


  '''Crear orden de compra y enviarla a otro grupo'''
  '''Ver diagrama enunciado'''
  def pedir_productos_finales
    '''1. Revisar Stock del otro grupo'''
    '''1.1 Si el stock esta disponible'''
    '''1.1.1 Crear orden de compra'''
    '''1.1.2 Enviar orden de compra'''
    '''1.1.3 Lidear con la respuesta'''
  end

  '''Manejar la respuesta del otro grupo'''
  '''POST a la URL'''
  def endpoint_notificacion
  end




end
