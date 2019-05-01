class CheckController < ApplicationController

# GET /check
def index
#Mover de recepcion a cocina
#Si llega un pedido, restar incoming
# productos = sku_with_stock(@@recepcion, @@api_key)[0]
# for p in productos
#   move_sku_almacen(@@recepcion, @@cocina, p["_id"])
# end

#Revisar inventarios minimios
lista_sku1 = skus_monitorear()
lista_sku2 = encontar_minimos(lista_sku1)



#Analizar lo del inventario
#Tomar en cuenta el incoming



#Pedir al sistema
#Pedir a otros grupos

render json: "hola", :status => 200
end

def skus_monitorear()
  listas_sku = []
  productos = Product.all
  productos.each do |product|

  if product["groups"].split(",")[0] == "1"
      listas_sku << product["sku"]
    end
  end
  return listas_sku
end

def encontar_minimos(lista_sku)
nueva_lista = []
skus  = MinimumStock.all
skus.each do |sks|
  for sku in lista_sku
    if sks["sku"] == sku.to_i
      min = sks["minimum_stock"]
      if min > 0
        nueva_lista << [sku, min]
      end
    end
  end
end
return nueva_lista
end




end
