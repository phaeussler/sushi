class RecepcionController < ApplicationController

# GET /recepcion
def index
  #1. Mover de recepcion a cocina
  #Si llega un pedido
  productos = sku_with_stock(@@recepcion, @@api_key)[0]
  for p in productos
    move_sku_almacen(@@recepcion, @@cocina, p["_id"])
  #Actualizar los INCOMING
  actualizar_incoming(productos)
  end

puts "RECEPCION"
msg = "Recepcion Vaciada"
render json: msg, :status => 200

end

#Cuando me llegan productos, debo sacarlos de incoming
def actualizar_incoming(productos)
  incoming = Product.all
  incoming.each do |inc|
    for producto in productos
      if inc["sku"] == producto["_id"].to_i
        if inc["incoming"] == nil
          inc["incoming"] = 0
        end

        if inc["incoming"] - producto["total"].to_i < 0
          inc["incoming"] = 0
        else
          inc["incoming"] = inc["incoming"] - producto["total"].to_i
        end
       end
    end
  end
end

end
