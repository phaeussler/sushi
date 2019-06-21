class RecepcionController < CheckController

  '''En este controlador lo que se hace es revisar el stock en el almacend de
  recepcion y se vacía, ya que el almacen de rececpcion es solo para recivir
  productos y no se debe almacenar en el.'''
  # GET /recepcion
  def index
    empty_reception
    #
    # '''Productos con stock en rececpcion'''
    # productos = sku_with_stock(@@recepcion, @@api_key)[0]
    # '''Por cada producto en la recepcion, moverlo a pulmon'''
    # if productos.length > 0
    #   recepcion_a_pulmon(productos)
    #   '''Se creo una columna llamada incoming en el modelo de productos, cada vez
    #   que se pide un producto, este producto tiene un tiempo de demora en llegar a
    #   la recepcion. Una vez que este llega debemos restarlo de la columna incoming
    #   que se utiliza para calcular el inventario mínimo del producto'''
    #   puts "RECEPCION VACIADA"
    # else
    #   puts "RECEPCION VACIA"
    # end
    msg = "Jobs"
    render json: msg,   :status => 200

  end


  def empty_reception
    puts "RECEPCION"
    contador = 0
    for i in sku_with_stock(@@recepcion, @@api_key)[0]
      lista_productos = request_product(@@recepcion, i["_id"], @@api_key)[0]
      for j in lista_productos
        if contador <= 1000
          move_product_almacen(j["_id"], @@despacho)
          move_product_almacen(j["_id"], @@pulmon)
          contador += 1
        end
      end
    end
  end




end
