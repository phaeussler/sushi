class CheckController < ApplicationController



# GET /check
def index
#1. Revisar inventarios minimios
lista_sku1 = skus_monitorear()

#Lista_sku2 tiene elememtos de la forma [sku, inventario minimo]
lista_sku2 = encontar_minimos(lista_sku1)

#Inventario en API
#Para cada sku, debo encontrar su inventario en la API
productos1 = sku_with_stock("5cbd3ce444f67600049431b8", "RAPrFLl620Cg$o")[0]

#Inventario "Incoming"
#Productos2 lista con elementos de la forma {"_id": sku,"total": inventario en API + el inventario incoming}
productos2 = encontrar_incoming(productos1)

puts productos2
#3.Ahora debemos analizar lo del inventario
#Proponer una regla de inventario
inventario(lista_sku2, productos2)

#4. Pedir al sistema
#5. Pedir a otros grupos

puts "INVENTARIO"
msg = "Inventario Revisado"
render json: msg, :status => 200
end

def actualizar_incoming2(sku, cantidad)
  incoming = Product.all
  incoming.each do |inc|
    if inc["sku"] == sku
        if inc["incoming"] == nil
          inc["incoming"] = 0


      else
          inc["incoming"] = inc["incoming"] + cantidad
        end
      end
    end
  end
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
  @stock = sku_with_stock("5cbd3ce444f67600049431b8", "RAPrFLl620Cg$o")[0]
  for sku in lista_sku
    revisado = false
    for producto in productos
      pr = producto["_id"].to_i
      #Comparo su inventario mínimo con el inventario actual
      if sku[0] == pr
        #Comparo el inventario real y el inventario mínimo
        revisado = true
        if sku[1] * 1.3 < producto["total"]
          '''ACÁ HAY QUE PEDIR PRODUCTO'''
          cantidad = 2*sku[1] - producto["total"]
          cantidad = pedir_producto(sku[0],cantidad)
          if cantidad > 0
            fabricar_producto(cantidad, sku[0])
          end
        end
      #Si el sku no esta en productos, es porque su stock es 0
      else
        revisado = true
        '''ACÁ HAY QUE PEDIR PRODUCTO'''
        cantidad = pedir_producto(sku[0], sku[1] * 2)
        if cantidad > 0
          fabricar_producto(sku[1]*2, sku[0])
        end
      end
    end
    if !revisado
      cantidad = pedir_producto(sku[0], sku[1] * 2)
      if cantidad > 0
        fabricar_producto(sku[1]*2, sku[0])
      end
    end

  end
end


def fabricar_producto(cantidad, sku)
  @cantidad = cantidad
  @sku = sku
  #Buscar la receta
  receta = Receipt.find_by sku: sku
  #Si el producto no requiere de otros para ser fabricado
  ing = Product.find_by sku: @sku
  if ing["ingredients"] == 0
    puts "No requiere materias primas"
    can1 = Ingredient.find_by sku_product: @sku
    can = (can1["quantity"] * @cantidad).to_i
    #Para cumplir con lotes de produccion
    n = 1
    while can >= can1["production_lot"] * n
      n = n + 1
    end
    can = can1["production_lot"] * n

    fabricarSinPago("RAPrFLl620Cg$o", @sku, can)

  #SI requiere de otros productos para ser fabricado
  else
  ingredientes = []
  numero = "1"
  for j in 0...6
    if receta["ingredient"+numero] != nil
      sku = Product.find_by name: receta["ingredient"+numero]
      ingredientes << sku["sku"]
    end
    numero = numero.to_i + 1
    numero = numero.to_s
  end

  #Ahora que tengo la receta tengo que ver cuanto tengo en inventario de las materias
  contador = 0
  for ingrediente in ingredientes
    #Cuanto de ese ingrediente necesito
    pr = Product.find_by sku: @sku
    quantity1 = Ingredient.find_by(sku_product: pr["sku"], sku_ingredient: ingrediente)

    if quantity1 == nil
      quantity = 0
    else
    quantity =(quantity1["quantity"] * @cantidad).to_i
    #Para cumplir con lotes de produccion
    n = 1
    while quantity >= quantity1["production_lot"] * n
      n = n + 1
    end
    quantity = quantity1["production_lot"] * n
    end

    #Veo si lo tengo en stock
    revisado = false
    for producto in @stock
      #Si lo tengo en stock
      if ingrediente == producto["_id"].to_i
        revisado = true
        #Revisar si tengo lo suficiente
        real = producto["total"].to_i
        if real > quantity
          contador = contador + 1
        else
          incoming = Product.find_by sku: ingrediente
          if incoming["incoming"] == nil
            incoming["incoming"] = 0
          end
          incoming = incoming["incoming"]
          total = real + incoming
          if total > quantity
          else
            prod = Product.find_by sku: ingrediente
            ingrediente = ingrediente.to_s
            fabricar = fabricarSinPago("RAPrFLl620Cg$o", ingrediente, quantity)

            respuesta = JSON.parse(fabricar.body)
            if respuesta["error"]
              if respuesta["error"] == "No existen suficientes materias primas"
                fabricar_producto(quantity, ingrediente.to_i)
              end
              if respuesta["error"].include? "Lote incorrecto"
                 num = respuesta["error"].scan(/\d/).join('')
                 num  = num.to_i
                 n = 1
                 while quantity > num * n
                   n = n + 1
                 end
                 fabricarSinPago("RAPrFLl620Cg$o", ingrediente, num*n)
                 actualizar_incoming2(ingrediente, num*n)
              end
            else
            actualizar_incoming2(ingrediente, quantity)
            end
          end
        end
      end
    end
    #Si no lo tengo en stock y tengo que pedirlo
    if !revisado
      prod = Product.find_by sku: ingrediente
      ingrediente = ingrediente.to_s
      fabricar = fabricarSinPago("RAPrFLl620Cg$o", ingrediente, quantity)

      respuesta = JSON.parse(fabricar.body)
      if respuesta["error"]
        if respuesta["error"] == "No existen suficientes materias primas"
          fabricar_producto(quantity, ingrediente.to_i)
        end
        if respuesta["error"].include? "Lote incorrecto"
           num = respuesta["error"].scan(/\d/).join('')
           num  = num.to_i
           n = 1
           while quantity > num * n
             n = n + 1
           end
           fabricarSinPago("RAPrFLl620Cg$o", ingrediente, num*n)
           actualizar_incoming2(ingrediente, num*n)
        end
      end
      actualizar_incoming2(ingrediente, quantity)
    end
  end

  #Si tengo las materias primas para fabricar
  if contador == ingredientes.length
      fabricar = fabricarSinPago("RAPrFLl620Cg$o", @sku, @cantidad)
      respuesta = JSON.parse(fabricar.body)
      if respuesta["error"]
        if respuesta["error"] == "No existen suficientes materias primas"
          fabricar_producto(@cantidad, @sku)
        end
        if respuesta["error"].include? "Lote incorrecto"
           num = respuesta["error"].scan(/\d/).join('')
           num  = num.to_i
           n = 1
           while @cantidad > num * n
             n = n + 1
           end
           fabricarSinPago("RAPrFLl620Cg$o", @sku, num*n)
           actualizar_incoming2(@sku, num*n)
        end
      actualizar_incoming2(@sku, @cantidad)
      end
  end
end
end

#Pedir materiales
def pedir_producto(sku, cantidad)
    #OJO QUE CUANDO PIDO DEBO ACTUALIZAR EL INCOMING
    puts "ACA TENGO QUE PEDIR PRODUCTO"
    producto = Product.find_by sku: sku
    groups = producto.groups
    # Deberiamos hacer una migracion para corregir esto
    if not producto.incoming
      producto.incoming = 0
    end
    #en forma aleatorea analizamos si nos pueden pasar los productos
    for group in groups.split(",").shuffle
      if cantidad > 0
        code, body = order_request(group, sku, "5cbd3ce444f67600049431b3", 1)
        # Si el codigo es positivo restamos la cantidad que nos pueden pasar
        if code == 201
          body = JSON.parse(body)
          if body["aceptado"]
            cantidad -= body['cantidad']
            producto.incoming += body['cantidad']
            puts "FIN DE PEDIR PRODUCTO"
            return 0
          end
        end
      end
      puts "FIN DE PEDIR PRODUCTO"
      return cantidad
    end






end
