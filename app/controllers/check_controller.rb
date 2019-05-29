
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
    '''3.2 Productos con inventario en pulmon'''
    pulmon = sku_with_stock(@@pulmon, @@api_key)[0]
    '''3.3 Encuentro el inventario incoming de los productos. Puede ser que ya
    hayamos pedido producto y no queremos ser redundantes. Productos2 es una lista
    de listas donde cada elemento tiene el formato [sku, inventario total, inventario minimo].
    Inventario total es inventario incoming + inventario en cocina'''
    '''Lista final tiene la lista con productos finales, lista productos es una lista de materias primas'''
    @lista_final, @lista_productos = encontrar_incoming(lista_sku2, pulmon)
    '''4. Mantener inventario de productos finales y de productos normales'''
    '''4. Analizar el tema de inventario'''
    # puts "-----------------PRODUCTOS-----------------"
    inventario_minimo(@lista_productos)
    # puts "-----------------PRODUCTOS FINALES-----------------"
    #inventario_productos_finales(@lista_final)
    puts "INVENTARIO"
    # despacho_a_pulmon
    # cocina_a_pulmon


    msg = "Inventario Revisado"
    render json: msg, :status => 200
  end

  def actualizar_incoming2(sku, cantidad)
    incoming = Product.find_by sku: sku.to_i
    if incoming["incoming"] == nil
      incoming["incoming"] = 0
    else
      incoming["incoming"] = incoming["incoming"] + cantidad
    end
    incoming.save
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
    nuevos_inventarios2 = []
    for producto in productos
      incoming = Product.find_by sku: producto[0].to_i
      if incoming["incoming"] == nil
         incoming["incoming"] = 0
         incoming.save
      end
      if producto[0] > 10000
        nuevos_inventarios << [producto[0], incoming["incoming"], producto[1].to_i]
      else
        nuevos_inventarios2 << [producto[0], incoming["incoming"], producto[1].to_i]
      end
    end
    for producto in inventario
      for prod in nuevos_inventarios
        if prod[0] == producto["_id"].to_i
          prod[1] += producto["total"].to_i
        end
      end
      for prod in nuevos_inventarios2
        if prod[0] == producto["_id"].to_i
          prod[1] += producto["total"].to_i
        end
      end
    end
    return nuevos_inventarios, nuevos_inventarios2
  end

  '''OJO QUE ACA PODEMOS INTEGRAR PRODUCTOS CRITICOS COMO EL ARROZ Y OTROS'''
  #Politica de inventario
  '''Política 1: Cuando tengo menos de la cantidad minima * 1.3 gatillo el pedido/produccion del producto'''
  '''Política 2: Mantendo 2 veces el stock mínimo en inventario'''
  '''Lista tiene la forma [sku, inventario total, inventario minimo]'''
  def inventario_minimo(lista)
    for producto in lista
      '''Aplico Politica 1 de Inventario'''
      if producto[1] <= producto[2] * 1.3
        '''Aplico Política 2 de Inventario'''
        cantidad = 2*producto[2] - producto[1]
        if cantidad == 0
          cantidad = 5
        end
        '''Pedir producto retorna 0 si logro pedir y la cantidad anterior si es
        que no logro pedir'''
        '''Implementar pedir productos por ftp'''
        puts "DEBERIA FABRICAR #{producto[0]} #{cantidad}"
        fabricar_producto(cantidad, producto[0], lista)
      else
        puts "NO DEBO FABRICAR #{producto[0]}, porque tengo #{producto[1]} y su minimo es #{producto[2]}}"
      end

    end
  end

  '''Podemos analizar la demanda para producir mas o menos de ciertos productos finales'''
  '''Asi se mantiene un inventario de acuerdo a la demanda'''
  def inventario_productos_finales(lista)
    for producto in lista
        #Por definir la cantidad
        cantidad = 4
        stockear_final(cantidad, producto[0], lista)
    end
  end

  '''Pedir el producto a la fábrica'''
  '''Lista tiene la forma [sku, inventario total, inventario minimo]'''
  def fabricar_producto(cantidad, sku, lista)
    puts "FABRICANDO #{sku} -> CANTIDAD #{cantidad}"
    @sku = sku
    @cantidad = production_lot(@sku, cantidad)
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    total_ingredientes = receta["ingredients_number"]

    '''2. Si el producto no requiere ingredeintes para ser fabricado'''
    if total_ingredientes == 0
      lot = production_lot(@sku, @cantidad)
      fabricar = fabricarSinPago(@@api_key, @sku.to_s, lot)
      respuesta = JSON.parse(fabricar.body)
      handle_response(respuesta, @sku, lot, lista)
    '''2.1 Si requiere de ingredientes para ser fabricado'''
    else
      ingredientes = []
      numero = "1"
      for j in 0...total_ingredientes
        if receta["ingredient"+numero] != nil
          sku = Product.find_by name: receta["ingredient"+numero]
          ingredientes << sku["sku"]
        end
          numero = numero.to_i + 1
          numero = numero.to_s
      end
      puts "#{@sku}"
      puts "Ingredientes -> #{total_ingredientes}"
      puts ingredientes
      '''3. Tengo la receta y los ingredientes, busco el inventario de las materias_primas'''
      contador = 0
      inventario = get_inventories
      for ingrediente in ingredientes
        '''3.1 Cuanto necesito de cada ingrediente'''
        '''3.1.1 Buscar la cantidad'''
        puts "Revisando Ingrediente -> #{ingrediente}"
        quantity = Ingredient.find_by(sku_product: @sku, sku_ingredient: ingrediente)
        lot = 0
        if quantity == nil
          lot = 0
        else
          lot = production_lot_ingredient(quantity ,@cantidad)
        end
        '''3.1.2 Reviso el stock que tengo de ese producto'''
        '''Si tengo el stock ahora'''
        revisado = false
        for producto in inventario
          if ingrediente == producto[:sku].to_i
            real = producto[:total].to_i
            if real > lot
              puts "Stock ahora"
              revisado = true
              contador = contador + 1
            end
          end
        end
        if !revisado
          '''Puede ser que el stock venga en camino'''
          for stock in lista
            '''Si lo tengo en mi lista de stock'''
            if ingrediente == stock[0].to_i
              '''Si el stock viene en camino'''
              revisado = true
              '''Si el stock viene en camino y no hay suficiente'''
              if stock[1] < lot
                fabricar = fabricarSinPago(@@api_key, ingrediente.to_s, lot)
                respuesta = JSON.parse(fabricar.body)
                handle_response(respuesta, ingrediente, lot, lista)
              else
                puts "Stock en camino"
              end
            end
          end
        end
        '''Si el producto no está en stock o hay que pedirlo'''
        if !revisado
          fabricar = fabricarSinPago(@@api_key, ingrediente.to_s, lot)
          respuesta = JSON.parse(fabricar.body)
          handle_response(respuesta, ingrediente, lot, lista)
        else
          puts "Ingrediente #{ingrediente} tenía stock"
        end
      end

      '''4. Si tengo las materias primas para fabricar'''
      if contador == total_ingredientes.to_i
        puts "Tengo todos los ingredientes y puedo fabricar"
        '''1. Mover los productos del pulmon a la cocina'''
        puts "Logica pulmon despacho"
        for ingrediente in ingredientes
          quantity = Ingredient.find_by(sku_product: @sku, sku_ingredient: ingrediente)
          lot = 0
          if quantity == nil
            lot = 0
          else
            lot = production_lot_ingredient(quantity ,@cantidad)
          end
          '''1.1 Analizar cuanto tengo en cocina'''
          puts "Revisando cuanto hay en despacho"
          despacho_a_pulmon
          restante = revisar_si_hay_en_despacho(ingrediente, lot)
          if restante > 0
            @@using_despacho = true
            puts "Moviendo de pulmon a despacho"
            move_q_products_almacen(@@pulmon, @@despacho, ingrediente.to_s, restante)
          end
        end
        '''2. Mandar a producir'''
        puts "Enviando a producir"
        fabricar = fabricarSinPago(@@api_key, @sku.to_s, @cantidad)
        '''3. Manejar respuesta'''
        puts "Manejando respuesta"
        respuesta = JSON.parse(fabricar.body)
        handle_response(respuesta, @sku, cantidad, lista)
        @@using_despacho = false
      end
    end
  end

  '''Este metodo se puede modificar para luego, evaluar si podemos hacer un pedido
  en el momento en que lo piden, estilo JUST IN TIME PRODUCTION. Revisando si tenemos
  los ingredientes y si los tenemos respondemos true y mandamos a fabricar. Luego llevamos
  un registro de las ordenes pendientes y cuando estaas vayan llegando las despachamso.'''
  def stockear_final(cantidad, sku, lista)
    puts "------------------------ FABRICANDO #{sku} ---------------------- \n"
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]
    @sku = sku
    @cantidad = production_lot(@sku, cantidad)
    '''2. Buscamos los ingredientes'''
    ingredientes = []
    numero = "1"
    for j in 0...total_ingredientes
      if receta["ingredient"+numero] != nil
        sku = Product.find_by name: receta["ingredient"+numero]
        ingredientes << sku["sku"]
      end
        numero = numero.to_i + 1
        numero = numero.to_s
    end
    puts "Ingredientes -> #{total_ingredientes}"
    puts ingredientes
    '''3. Stock de ingredientes'''
    contador = 0
    inventario =  get_inventories
    for ingrediente in ingredientes
      '''3.1 Cuanto necesito de cada ingrediente'''
      quantity = Ingredient.find_by(sku_product: @sku, sku_ingredient: ingrediente)
      lot = 0
      if quantity == nil
        lot = 0
      else
        lot = production_lot_ingredient(quantity ,@cantidad)
      end
      revisado = false
      '''3.2 Stock de cada producto'''
      '''Lo puedo tener en inventario'''
      for producto in inventario
        if ingrediente == producto[:sku].to_i
          real = producto[:total].to_i
          if real >= lot
            revisado = true
            contador = contador + 1
          end
        end
      end
      if !revisado
        '''El stock puede estar en camino'''
        for stock in lista
          if ingrediente == stock[0].to_i
            revisado == true
            if stock[1] < lot
                fabricar_producto(lot, ingrediente, lista)
            end
          end
        end
      end
      if !revisado
        fabricar_producto(lot, ingrediente, lista)
      end
    end
    if contador == total_ingredientes
      #fabricar_final(@cantidad, @sku)
    end
  end

  def evaluar_fabricar_final(cantidad, sku)
    puts "--------------- EVALUANDO #{sku} --------------------"
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]
    @sku = sku
    @cantidad = production_lot(@sku, cantidad)
    if total_ingredientes == 0
      return true
    else
      '''2. Buscamos los ingredientes'''
      ingredientes = []
      numero = "1"
      for j in 0...total_ingredientes
        if receta["ingredient"+numero] != nil
          sku = Product.find_by name: receta["ingredient"+numero]
          ingredientes << sku["sku"]
        end
          numero = numero.to_i + 1
          numero = numero.to_s
      end
      puts "Ingredientes -> #{total_ingredientes}"
      puts ingredientes
      '''3. Stock de ingredientes'''
      contador = 0
      inventario =  get_inventories
      for ingrediente in ingredientes
        '''3.1 Cuanto necesito de cada ingrediente'''
        quantity = Ingredient.find_by(sku_product: @sku, sku_ingredient: ingrediente)
        lot = 0
        if quantity == nil
          lot = 0
        else
          lot = production_lot_ingredient(quantity ,@cantidad)
        end
        revisado = false
        '''3.2 Stock de cada producto'''
        '''Lo puedo tener en inventario'''
        for producto in inventario
          if ingrediente == producto[:sku].to_i
            real = producto[:total].to_i
            if real >= lot
              revisado = true
              contador = contador + 1
            end
          end
        end
      end
      if contador == total_ingredientes
        return true
      else
        return false
      end
    end


  end

  def fabricar_final(cantidad, sku)
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]
    @sku = sku
    @cantidad = production_lot(@sku, cantidad)
    if total_ingredientes == 0
      lot = production_lot(@sku, @cantidad)
      fabricar = fabricarSinPago(@@api_key, @sku.to_s, lot)
      '''5. Manejar respuesta'''
      puts "Manejando respuesta"
      respuesta = JSON.parse(fabricar.body)
      return respuesta
    '''2.1 Si requiere de ingredientes para ser fabricado'''
    else
      '''2. Buscamos los ingredientes'''
      ingredientes = []
      numero = "1"
      for j in 0...total_ingredientes
        if receta["ingredient"+numero] != nil
          sku = Product.find_by name: receta["ingredient"+numero]
          ingredientes << sku["sku"]
        end
          numero = numero.to_i + 1
          numero = numero.to_s
      end
      puts "Ingredientes -> #{total_ingredientes}"
      puts ingredientes
      '''3. Mover los productos del pulmon a la cocina'''
      puts "Analizando"
      for ingrediente in ingredientes
        quantity = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
        lot = 0
        if quantity == nil
          lot = 0
        else
          lot = production_lot_ingredient(quantity ,@cantidad)
        end
        '''1.1 Analizar cuanto tengo en cocina'''
        puts "Revisando cuanto hay en despacho"
        despacho_a_pulmon
        restante = revisar_si_hay_en_despacho(ingrediente, lot)
        if restante > 0
          puts "Moviendo de pulmon a despacho"
          move_q_products_almacen(@@pulmon, @@despacho, ingrediente.to_s, restante)
        end
      end
      '''4. Mandar a producir'''
      puts "Enviando a producir"
      lot = production_lot(@sku, @cantidad)
      fabricar = fabricarSinPago(@@api_key, @sku.to_s, lot)
      #fabricar = fabricarSinPago(@@api_key, @sku.to_s, @cantidad)
      '''5. Manejar respuesta'''
      puts "Manejando respuesta"
      respuesta = JSON.parse(fabricar.body)
      return respuesta
      #handle_response(respuesta, sku.to_s, cantidad, lista)
    end
  end

  '''funcion para checkear si otro grupo tiene stock de un producto'''
  def check_other_inventories(group, sku)
    puts "check_other_inventories grupo #{group}"
    code, body = get_request(group,"inventories")
    if code == 200
      for dic in JSON.parse(body)
        if dic["sku"].to_i == sku
          puts "check_other_inventories encontado"
          return true
        end
      end
    end
    puts "check_other_inventories NO encontado"
    return false
  end

  '''Funcion para pedir los productos a otro grupo inputs(sku:str, cantidad:int), output cantidad_faltante:int'''
  def pedir_producto(sku, cantidad)
      producto = Product.find_by sku: sku
      groups = producto.groups
      # Deberiamos hacer una migracion para corregir esto
      if not producto.incoming
        producto.incoming = 0
      end
      # en forma aleatorea analizamos si es que nos pueden pasar los productos
      puts "groups #{groups}"
      for group in groups.split(",").shuffle
        puts group
        unless group =="1"
          if check_other_inventories(group, sku)
            puts "\nGrupo #{group} cantidad #{cantidad}"
            if cantidad > 0
              code, body, headers = order_request(group, sku, @@recepcion, cantidad)
              # Si el codigo es positivo restamos la cantidad que nos pueden pasar
              puts "Grupo #{group}, code #{code}"
              if code == 200 or code == 201
                body = JSON.parse(body)
                puts "Body #{body}"
                if body["aceptado"]
                  begin  # "try" block
                    cantidad -= body['cantidad']
                    producto.incoming += body['cantidad']
                    producto.save
                    puts "FIN DE PEDIR PRODUCTO 0"
                    return 0
                  rescue TypeError => e
                    puts e
                    if body['cantidad']
                      producto.incoming += cantidad
                      producto.save
                    end
                    puts "FIN DE PEDIR PRODUCTO 0"
                    return 0
                  end
                end
              end
            end
          end
        end
      end
      puts "\nFIN DE PEDIR PRODUCTO #{cantidad}\n\n"
      return cantidad
  end

  '''Le pide un ingrediente a los grupo y retorna la cantidad faltante'''
  def pedir_otro_grupo_oc(sku, cantidad)
    puts "PIDIENDO INGREDIENTE A OTRO GRUPO"
    producto = Product.find_by sku: sku
    groups = producto.groups
    # Deberiamos hacer una migracion para corregir esto, ya que hay valores nul
    if not producto.incoming
      producto.incoming = 0
    end
    # en forma aleatorea analizamos si es que nos pueden pasar los productos de los grupos que lo prodcen
    for group in groups.split(",").shuffle
      unless group ==1
        if cantidad > 0
          # Primero creamos la orden de compra
          puts "Metodo oc"
          # oc_code, oc_body = create_oc(sku, cantidad, group)
          # puts "body_oc #{oc_body}"
          oc = create_oc(sku, cantidad, group)
          oc_code = oc.code
          oc_body = JSON.parse(oc.body)

          if oc_code == 200

            # Si es aceptado hacemos el request al otro grupo con el id de la orden
            code, body, headers = order_request(group, sku, @@recepcion, cantidad, oc_body["_id"])
            # else
            #   puts "Metodo sin oc"
            #   code, body, headers = order_request(group, sku, @@recepcion, cantidad)
            # end
            # Si el codigo es positivo restamos la cantidad que nos pueden pasar
            puts "ORDER REQUEST -> #{code}"
            # Reviso si fue aceptado, deberia ser 201 el codigo pero hay grupos que lo tienen implementado con 200
            if code == 200 or code == 201
              puts "#{headers} #{body}"
              body = JSON.parse(body)
              if body["aceptado"]
                # Si es aceptado entonces le agrego a incoming
                begin  # "try" block
                  cantidad -= body['cantidad']
                  producto.incoming += body['cantidad']
                  producto.save
                  puts 'pedir_ingrediente_oc 0'
                  return cantidad
                rescue TypeError => e
                  # El grupo 6 retorna cantidad true en vez de numero
                  if body['cantidad']
                    producto.incoming += cantidad
                    producto.save
                    puts 'pedir_ingrediente_oc 0'
                    return 0
                  end
                end
              end
            end
          end
        end
      end
      return cantidad
    end
    return cantidad
  end

  '''Calcula el lote de produccion'''
  def production_lot(sku, cantidad)
    quantity1 = Product.find_by sku: sku.to_i
    quantity = quantity1["production_lot"].to_i
    n = 1
    while cantidad > (quantity * n).to_i
      n = n + 1
    end
    return (quantity * n).to_i
  end

  '''Calcula lote de produccion de un ingrediente'''
  def production_lot_ingredient(quantity1, cantidad)
    quantity = quantity1["production_lot"]
    n = 1
    while cantidad > (quantity * n).to_i
      n = n + 1
    end
    return (quantity * n).to_i
  end

  '''Maneja las respuestas de fabricarSinPago'''
  def handle_response(respuesta, ingrediente, quantity, lista)
    if respuesta["error"]
      if respuesta["error"] == "No existen suficientes materias primas"
        if respuesta["detalles"]
          for detalle in respuesta["detalles"]
          cantidad = detalle[0]["requerido"].to_i - detalle[0]["disponible"].to_i
          fabricar_producto(cantidad, detalle[0]["sku"], lista)
          end
        else
          fabricar_producto(quantity, ingrediente.to_i, lista)
        end
      end
      if respuesta["error"].include? "sku no"
        puts "PIDIENDO A OTRO GRUPO"
        pedir_otro_grupo_oc(ingrediente, quantity)
        '''OJO MANEJAR LA RESPUESTA DE OTRO GRUPO'''
      end
      if respuesta["error"].include? "Lote incorrecto"
        num = respuesta["error"].scan(/\d/).join('')
        num  = num.to_i
        n = 1
        while quantity > num * n
          n = n + 1
        end
        fabricarSinPago(@@api_key, ingrediente.to_s, num*n)
        actualizar_incoming2(ingrediente, num*n)
      end
    else
      actualizar_incoming2(ingrediente, quantity)
    end
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

  def revisar_si_hay_en_despacho(sku, cantidad)
    sku_cocina = sku_with_stock(@@despacho, @@api_key)[0]
    restante = cantidad.to_i
    for i in sku_cocina
      if i["_id"] == sku.to_s
        restante -= i["total"].to_i
      end
    end
    return restante
  end

end
