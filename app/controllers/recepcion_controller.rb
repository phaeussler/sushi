class RecepcionController < CheckController

  '''En este controlador lo que se hace es revisar el stock en el almacend de
  recepcion y se vacía, ya que el almacen de rececpcion es solo para recivir
  productos y no se debe almacenar en el.'''
  # GET /recepcion
  def index
    puts "RECEPCION"
    '''Primero los productos importantes'''
    puts "REVISANDO PULMON"
    productos_pulmon = sku_with_stock(@@pulmon, @@api_key)[0]
    if productos_pulmon.length > 0
      for producto in productos_pulmon
        if producto["_id"].to_i > 10000
          move_sku_almacen(@@pulmon, @@cocina, producto["_id"])
        end
      end
    end
    puts "REVISANDO RECEPCION"
    '''Productos con stock en rececpcion'''
    productos = sku_with_stock(@@recepcion, @@api_key)[0]
    '''Por cada producto en la recepcion, moverlo a cocina'''
    if productos.length > 0
      for prod in productos
       move_sku_almacen(@@recepcion, @@cocina, prod["_id"])
      end
    '''Se creo una columna llamada incoming en el modelo de productos, cada vez
    que se pide un producto, este producto tiene un tiempo de demora en llegar a
    la recepcion. Una vez que este llega debemos restarlo de la columna incoming
    que se utiliza para calcular el inventario mínimo del producto'''
      actualizar_incoming(productos)
      puts "RECEPCION VACIADA"
    else
      puts "RECEPCION VACIA"
    end

    msg = "Recepcion Vaciada"
    render json: msg,   :status => 200

  end

  '''Esta es la funcion que actualiza el incoming de cada producto'''
  def actualizar_incoming(productos)
    for producto in productos
      incoming = Product.find_by sku: producto["_id"].to_i
      if incoming["incoming"] == nil
        incoming["incoming"] = 0
      end
      if incoming["incoming"] - producto["total"].to_i < 0
        incoming["incoming"] = 0
      else
        incoming["incoming"] -= producto["total"].to_i
      end
      incoming.save
    end
  end


end
