class CheckController < ApplicationController

  '''Queremos revisar el inventario mínimo para cada producto que nos piden'''
  # GET /check
  def index
  '''1. Encontramos los productos que debemos mantener en un mínimo'''
  lista_sku1 = skus_monitorear()
  '''2. Encontramos el mínimo para cada producto. Esta funcion nos devuelve una
  lista de lista con cada elemento de la forma [sku, inventario minimo]'''
  lista_sku2 = encontar_minimos(lista_sku1)
  '''3. Para cada uno de los productos debo encontrar su inventario'''
  '''3.1 Encuentro los productos con stock en cocina'''
  productos1 = sku_with_stock(@@cocina, @@api_key)[0]
  '''3.2 Encuentro el inventario incoming de los productos. Puede ser que ya
  hayamos pedido producto y no queremos ser redundantes. Productos2 es una lista
  de listas donde cada elemento tiene el formato [sku, inventario total, inventario minimo].
  Inventario total es inventario incoming + inventario en cocina'''
  lista_final = encontrar_incoming(lista_sku2, productos1)
  '''4. Analizar el tema de inventario'''
  inventario(lista_final)

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
    for sku in lista_sku
      min = MinimumStock.find_by sku: sku
      if min
        nueva_lista << [sku, min["minimum_stock"]]
      else
        nueva_lista << [sku, 0]
      end
    end
    return nueva_lista
  end

  #Suma el inventario real con lo ya pedido
  def encontrar_incoming(productos, inventario)
    nuevos_inventarios = []
    for producto in productos
      incoming = Product.find_by sku: producto[0].to_i
      if incoming["incoming"] == nil
         incoming["incoming"] = 0
      end
      nuevos_inventarios << [producto[0], incoming["incoming"], producto[1].to_i]
    end
    for producto in inventario
      for prod in nuevos_inventarios
        if prod[0] == producto["_id"].to_i
          prod[1] += producto["total"].to_i
        end
      end
    end
    return nuevos_inventarios
  end

  #Politica de inventario
  '''Política 1: Cuando tengo menos de la cantiad minima * 1.3 gatillo el pedido/produccion del producto'''
  '''Política 2: Mantendo 2 veces el stock mínimo en inventario'''
  '''Lista tiene la forma [sku, inventario total, inventario minimo]'''
  def inventario(lista)
    for producto in lista
      '''Aplico Politica 1 de Inventario'''
      if producto[1] < producto[2] * 1.3
        '''Aplico Política 2 de Inventario'''
        cantidad = 2*producto[2] - producto[1]
        puts "Cantidad a pedir"
        puts cantidad
        puts "\n"
        # cantidad = pedir_producto(producto[0],cantidad)
        # if cantidad > 0
        #   fabricar_producto(cantidad, producto[0])
        #end
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
