
class CheckController < ApplicationController


  '''Queremos revisar el inventario mínimo para cada producto que nos piden'''
  # GET /check
  def index
    satisfy_inventory_level3()


    msg = "Inventario Revisado"
    render json: msg, :status => 200
  end

  

  '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
  def satisfy_inventory_level1
    puts "--satisfy_inventory_level1--"
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 1
          '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
          if product["groups"].split(",")[0] == "1"
            lot = production_lot(product[:sku], 100)
            fabricar = fabricarSinPago(@@api_key, product[:sku], lot)
            respuesta = JSON.parse(fabricar.body)
            handle_response(respuesta, sku, lot)
          else
            pedir_otro_grupo_oc(product[:sku], 10)
          end
        end
      end
    end
  end

  '''Level 2 es productos que tenemos que mandar a fabricar'''
  def satisfy_inventory_level2
    puts "--satisfy_inventory_level2--"
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 2
          fabricar_producto(5, product[:sku], 'despacho')
        end
      end
    end
  end

  '''Level 3 es productos que tenemos que mandar a fabricar'''
  def satisfy_inventory_level3
    puts "--satisfy_inventory_level3--"
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 3
          fabricar_producto(1, product[:sku], 'cocina')
        end
      end
    end
  end

  '''Pedir el producto a la fábrica'''
  '''Lista tiene la forma [sku, inventario total, inventario minimo]'''
  def fabricar_producto(cantidad, sku, to)
    puts "FABRICANDO #{sku} -> CANTIDAD #{cantidad}"
    sku = sku
    cantidad = production_lot(sku, cantidad)
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    total_ingredientes = receta["ingredients_number"]

    ingredientes = get_ingredients_list(total_ingredientes, receta)
    puts "#{sku}"
    puts "Ingredientes -> #{total_ingredientes}"
    puts ingredientes
    

    '''4. Si tengo las materias primas para fabricar'''
    if check_ingredients_stock(sku, cantidad, total_ingredientes, ingredientes)
      puts "Tengo todos los ingredientes y puedo fabricar"
      '''1. Mover los productos del pulmon a la cocina'''
      puts "Logica pulmon despacho"
      '''O. Vaciar el despacho '''
      puts "PRIMERO VACIO DESPACHO"
      if !@@using_despacho
        @@using_despacho = true
        despacho_a_pulmon()
        @@using_despacho = false
      end
      move_ingredientes(sku, cantidad, ingredientes, to)
      '''2. Mandar a producir'''
      puts "Enviando a producir"
      fabricar = fabricarSinPago(@@api_key, sku.to_s, cantidad)
      '''3. Manejar respuesta'''
      puts "Manejando respuesta"
      respuesta = JSON.parse(fabricar.body)
      handle_response(respuesta, sku, cantidad)
      @@using_despacho = false
    end
  end

  def evaluar_fabricar_final(cantidad, sku)
    puts "--------------- EVALUANDO #{sku} --------------------"
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]
    sku = sku
    cantidad = production_lot(sku, cantidad)
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
        quantity = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
        lot = 0
        if quantity == nil
          lot = 0
        else
          lot = production_lot_ingredient(quantity ,cantidad)
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
    sku = sku
    cantidad = production_lot(sku, cantidad)
    if total_ingredientes == 0
      lot = production_lot(sku, cantidad)
      fabricar = fabricarSinPago(@@api_key, sku.to_s, lot)
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
      puts "PRIMERO VACIAR DESPACHO"
      puts "PRIMERO VACIO DESPACHO"
      if !@@using_despacho
        @@using_despacho = true
        despacho_a_pulmon
        @@using_despacho = false
      end
      puts "Analizando"
      for ingrediente in ingredientes
        quantity = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
        lot = 0
        if quantity == nil
          lot = 0
        else
          lot = production_lot_ingredient(quantity ,cantidad)
        end
        '''1.1 Analizar cuanto tengo en cocina'''
        puts "Revisando cuanto hay en despacho"
        restante = revisar_si_hay_en_despacho(ingrediente, lot)
        if restante > 0
          puts "Moviendo de pulmon a despacho"
          move_q_products_almacen(@@pulmon, @@despacho, ingrediente.to_s, restante)
        end
      end
      '''4. Mandar a producir'''
      puts "Enviando a producir"
      lot = production_lot(sku, cantidad)
      fabricar = fabricarSinPago(@@api_key, sku.to_s, lot)
      #fabricar = fabricarSinPago(@@api_key, sku.to_s, cantidad)
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
            puts "#id orden de compra #{oc_body["_id"]} #{oc_body["_id"].class.name}"
            # Si es aceptado hacemos el request al otro grupo con el id de la orden
            code, body, headers = order_request(group, sku, @@recepcion, cantidad, oc_body["_id"])
            # else
            #   puts "Metodo sin oc"
            #   code, body, headers = order_request(group, sku, @@recepcion, cantidad)
            # end
            # Si el codigo es positivo restamos la cantidad que nos pueden pasar
            require 'colorize'
            puts "#{'ORDER REQUEST'.green} -> #{(code == 200 or code == 201) ? code.to_s.green : code.to_s.red} #{body}"
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
    end
    return cantidad
  end

  '''Calcula el lote de produccion'''
  def production_lot(sku, cantidad)
    quantity1 = Product.find_by sku: sku.to_i
    quantity = quantity1["production_lot"].to_i
    # n = (cantidad/quantity).ceil
    n = 1
    while cantidad > (quantity * n).to_i
      n = n + 1
    end
    return (quantity * n).to_i
  end

  '''Calcula lote de produccion de un ingrediente'''
  def production_lot_ingredient(ingrediente, cantidad)
    quantity = ingrediente["production_lot"]
    # n = (cantidad/quantity).ceil
    n = 1
    while cantidad > (quantity * n).to_i
      n = n + 1
    end
    return (quantity * n).to_i
  end

  '''Maneja las respuestas de fabricarSinPago'''
  def handle_response(respuesta, ingrediente, quantity)
    if respuesta["error"]
      if respuesta["error"] == "No existen suficientes materias primas"
        if respuesta["detalles"]
          for detalle in respuesta["detalles"]
          cantidad = detalle[0]["requerido"].to_i - detalle[0]["disponible"].to_i
          fabricar_producto(cantidad, detalle[0]["sku"])
          end
        else
          fabricar_producto(quantity, ingrediente.to_i)
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
        # actualizar_incoming2(ingrediente, num*n)
      end
    else
      # actualizar_incoming2(ingrediente, quantity)
    end
  end


  def get_ingredients_list(total_ingredientes, receta)
    numero = "1"
    ingredientes = []
    for j in 0...total_ingredientes
      if receta["ingredient"+numero] != nil
        producto = Product.find_by name: receta["ingredient"+numero]
        ingredientes << producto["sku"]
      end
        numero = numero.to_i + 1
        numero = numero.to_s
    end
    return ingredientes
  end

  def check_ingredients_stock(sku, cantidad, total_ingredientes, ingredientes)
    '''3. Tengo la receta y los ingredientes, busco el inventario de las materias_primas'''
    contador = 0
    inventario = get_dict_inventories
    for ingrediente in ingredientes
      '''3.1 Cuanto necesito de cada ingrediente'''
      '''3.1.1 Buscar la cantidad'''
      puts "Revisando Ingrediente -> #{ingrediente}"
      ingredient = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
      lot = 0
      if ingredient == nil
        lot = 0
      else
        lot = production_lot_ingredient(ingredient ,cantidad)
      end
      '''3.1.2 Reviso el stock que tengo de ese producto'''
      '''Si tengo el stock ahora'''
      revisado = false
      real = inventario[:ingrediente] ? inventario[:ingrediente] : 0
      if real >= lot
        puts "Stock ahora"
        revisado = true
        contador = contador + 1
      end
      '''Si el producto no está en stock o hay que pedirlo'''
      if !revisado
        fabricar = fabricarSinPago(@@api_key, ingrediente.to_s, lot)
        respuesta = JSON.parse(fabricar.body)
        handle_response(respuesta, ingrediente, lot)
      else
        puts "Ingrediente #{ingrediente} tenía stock"
      end
    end
    return contador == total_ingredientes.to_i
  end

  def move_ingredientes(sku, cantidad, ingredientes, to)
    for ingrediente in ingredientes
      quantity = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
      lot = 0
      if quantity == nil
        lot = 0
      else
        lot = production_lot_ingredient(quantity ,cantidad)
      end
      '''4.1 Analizar cuanto tengo en cocina'''
      @@using_despacho = true
      puts "Moviendo de pulmon a despacho"
      if to == 'despacho'
        move_q_products_almacen(@@pulmon, @@despacho, ingrediente.to_s, lot)
      elsif to == 'cocina'
        move_q_products_almacen(@@pulmon, @@cocina, ingrediente.to_s, lot)
      end
    end
  end
end
