class CheckController < ApplicationController

# GET /check
def index
#1. Revisar inventarios minimios
lista_sku1 = skus_monitorear()
#Lista_sku2 tiene elememtos de la forma [sku, inventario minimo]
lista_sku2 = encontar_minimos(lista_sku1)
#Inventario en API
#Para cada sku, debo encontrar su inventario en la API
productos1 = sku_with_stock(@@cocina, @@api_key)[0]
#Inventario "Incoming"
#Productos2 lista con elementos de la forma {"_id": sku,"total": inventario en API + el inventario incoming}
productos2 = encontrar_incoming(productos1)


#3.Ahora debemos analizar lo del inventario
#Proponer una regla de inventario
inventario(lista_sku2, productos2)

#4. Pedir al sistema
#5. Pedir a otros grupos

puts "INVENTARIO"
msg = "Inventario Revisado"
render json: msg, :status => 200
end

#Entrega los productos que debemos tener stock mínimo
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

#Retorna el minimo de los productos que debemos tener
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

#Suma el inventario real con lo ya pedido
def encontrar_incoming(productos)
  nuevos_inventarios = []
  incoming = Product.all
  incoming.each do |inc|
    for producto in productos
      if inc["sku"] == producto["_id"].to_i
        if inc["incoming"] == nil
          inc["incoming"] = 0
        end
        producto["total"] = producto["total"].to_i + inc["incoming"]
        nuevos_inventarios << producto
       end
    end
  end
  return nuevos_inventarios
end

#Politica de inventario
'''Política 1: Cuando tengo menos de la cantiad minima * 1.3 gatillo el pedido/produccion del producto'''
'''Política 2: Mantendo 2 veces el stock mínimo en inventario'''
def inventario(lista_sku, productos)
  for sku in lista_sku
    for producto in productos
      pr = producto["_id"].to_i
      #Comparo su inventario mínimo con el inventario actual
      if sku[0] == pr
        #Comparo el inventario real y el inventario mínimo
        if sku[1] * 1.3 < producto["total"]
          '''ACÁ HAY QUE PEDIR PRODUCTO'''
          cantidad = 2*sku[1] - producto["total"]
          pedir_producto(catidad)
        end
      #Si el sku no esta en productos, es porque su stock es 0
      else
        '''ACÁ HAY QUE PEDIR PRODUCTO'''
        pedir_producto(sku[1] * 2)
      end
    end
  end
end

#Pedir materiales
def pedir_producto(cantidad)
  #OJO QUE CUANDO PIDO DEBO ACTUALIZAR EL INCOMING
  puts cantidad
  puts "ACA TENGO QUE PEDIR PRODUCTO"
end



end
