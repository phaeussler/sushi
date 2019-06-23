class CheckController < ApplicationController
  helper_method :pedir_un_producto
  '''Queremos revisar el inventario mínimo para cada producto que nos piden'''
  # GET /check
  def index
    msg = "Inventario Revisado"
    render json: msg, :status => 200
  end

  def pedir_un_producto(sku)
    puts "pedir_un_producto #{sku}"
    product = Product.find_by sku: sku.to_i
    if product.level == 1
      '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
      # if product["groups"].split(",")[0] == "1"
        lot = production_lot(product[:sku], 10)
        fabricar = fabricarSinPago(@@api_key, product[:sku], lot)
      #   respuesta = JSON.parse(fabricar.body)
      #   handle_response(respuesta, sku, lot)
      # else
      #   pedir_otro_grupo_oc(product[:sku], 10)
      # end
    elsif product.level == 2
      fabricar_producto(5, product[:sku], 'despacho')
    elsif product.level == 3
      fabricar_producto(1, product[:sku], 'cocina')
    end
  end

  def satisfy_inventory_level1_groups
    puts "--satisfy_inventory_level1_gropus--".green
    cantidad = 10
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      #puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 1
          '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
          lot = production_lot(product[:sku], cantidad)
          '''pedir_otro_grupo_oc retorna 0 si el otro grupo te aceptó y un numero > 0 si no aceptó'''
          resp = pedir_otro_grupo_oc(product[:sku], lot)
        end
      end
    end
  end

  '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
  def satisfy_inventory_level1
    puts "--satisfy_inventory_level1_--".green
    cantidad = 50
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      #puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 1
          '''Level 1 son ingredientes que podemos fabricar o pedir a otro grupo'''
          lot = production_lot(product[:sku], cantidad)
          fabricar = fabricarSinPago(@@api_key, product[:sku], lot)
          respuesta = JSON.parse(fabricar.body)
          handle_response(respuesta, product[:sku], lot, 'despacho')
        end
      end
    end
  end

  '''Level 2 es productos que tenemos que mandar a fabricar'''
  def satisfy_inventory_level2
    puts "--satisfy_inventory_level2--".green
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      #puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
      if product["min"]*1.3 >= in_cellar and in_cellar < product["max"]
        if product.level == 2
          fabricar_producto(5, product[:sku], 'despacho')
        end
      end
    end
  end

  '''Level 3 es productos que tenemos que mandar a fabricar'''
  def satisfy_inventory_level3
    puts "--satisfy_inventory_level3--".green
    inventories = get_dict_inventories()
    for product in Product.all
      in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
      #puts "product -> sku: #{product.sku} min: #{product.min} tenemos :#{in_cellar} max :#{product.max} level:#{product.level} #{product['min']*1.3 >= in_cellar and in_cellar < product['max']}"
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
    sku = sku
    cantidad = production_lot(sku, cantidad)
    puts "\nProduciendo #{sku} cantidad #{cantidad}".green
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    total_ingredientes = receta["ingredients_number"]

    ingredientes = get_ingredients_list(total_ingredientes, receta)
    puts "Ingredientes -> #{total_ingredientes}".yellow
    puts ingredientes


    '''4. Si tengo las materias primas para fabricar'''
    check_ingredientes, total = check_ingredients_stock(sku, cantidad, total_ingredientes, ingredientes)
    if check_ingredientes
      puts "Tengo todos los ingredientes y puedo fabricar #{sku}".green
      '''1. Mover los productos del pulmon a la cocina'''
      restante = restante_despacho()
      if total > restante
        puts "Moviendo #{total - restante} a pulmon para vaciar despacho"
        if !@@using_despacho
          @@using_despacho = true
          despacho_a_pulmon(total - restante)
          @@using_despacho = false
        end
      end
      move_ingredientes(sku, cantidad, ingredientes, to)
      '''2. Mandar a producir'''
      # puts "Enviando a producir".red
      fabricar = fabricarSinPago(@@api_key, sku.to_s, cantidad)
      '''3. Manejar respuesta'''
      respuesta = JSON.parse(fabricar.body)
      handle_response(respuesta, sku, cantidad, to)
      @@using_despacho = false
    end
  end

  def evaluar_fabricar_final(cantidad, sku)
    puts "--------------- EVALUANDO #{sku} --------------------"
    sku = sku
    cantidad = production_lot(sku, cantidad)
    '''Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]
    '''Obtenemos ingredientes'''
    ingredientes = get_ingredients_list(total_ingredientes, receta)
    puts "#{sku}"
    puts "Ingredientes -> #{total_ingredientes}"
    puts ingredientes
    '''Revisamos su stock'''
    check, total = check_ingredients_stock(sku, cantidad, total_ingredientes, ingredientes)
    return check
  end

  def fabricar_final(cantidad, sku)
    puts "------------- FABRICANDO PRODUCTO FINAL #{sku} --------------".green
    sku = sku
    cantidad = production_lot(sku, cantidad)
    '''1. Buscamos la receta'''
    receta = Receipt.find_by sku: sku
    puts "RECETA #{sku}"
    total_ingredientes = receta["ingredients_number"]

    '''2. Buscamos sus ingredientes '''
    ingredientes = get_ingredients_list(total_ingredientes, receta)
    puts "Produciendo #{sku}"
    puts "Ingredientes -> #{total_ingredientes}"
    puts ingredientes

    '''Enviamos a producir'''
    puts "Tengo todos los ingredientes y puedo fabricar #{sku}"
    check_ingredientes, total = check_ingredients_stock(sku, cantidad, total_ingredientes, ingredientes)
    restante = restante_cocina()
    if total > restante
      puts "Moviendo #{total - restante} de cocina para poder producir"
      if !@@using_despacho
        @@using_despacho = true
        cocina_a_pulmon(total - restante)
        @@using_despacho = false
      end
    end
    move_ingredientes(sku, cantidad, ingredientes, 'cocina')
    '''Mandar a producir'''
    puts "Enviando a producir"
    fabricar = fabricarSinPago(@@api_key, sku.to_s, cantidad)
    '''3. Manejar respuesta'''

    respuesta = JSON.parse(fabricar.body)
    return respuesta
    # handle_response(respuesta, sku, cantidad)
    # @@using_despacho = false
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
    puts "Pidiendo ingrendiente a otro grupo".green
    producto = Product.find_by sku: sku
    groups = producto.groups
    # Deberiamos hacer una migracion para corregir esto, ya que hay valores nul
    if not producto.incoming
      producto.incoming = 0
    end
    # en forma aleatorea analizamos si es que nos pueden pasar los productos de los grupos que lo prodcen
    for group in groups.split(",").shuffle
      unless group == 1
        if cantidad > 0
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
            puts "Pidiendo a grupo #{group}".blue
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
                  #puts 'pedir_ingrediente_oc 0'
                  return cantidad
                rescue TypeError => e
                  # El grupo 6 retorna cantidad true en vez de numero
                  if body['cantidad']
                    producto.incoming += cantidad
                    producto.save
                    #puts 'pedir_ingrediente_oc 0'
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
    product = Product.find_by sku: sku.to_i
    quantity = product["production_lot"].to_i
    n = (cantidad.to_f/quantity).ceil
    return [(quantity * n).to_i, quantity].max
  end

  def production_lot_ingredient(sku, ingrediente, cantidad)
    product = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
    quantity = (cantidad / product["production_lot"].to_i).ceil
    n = quantity * product["equivalence_unit_hold"]
    return n.to_i
  end

  def restante_despacho
    despacho = request_system('almacenes', 'GET', @@api_key)[0][1]
    return despacho["totalSpace"].to_i - despacho["usedSpace"].to_i
  end

  def restante_cocina
    cocina = request_system('almacenes', 'GET', @@api_key)[0][5]
    return cocina["totalSpace"].to_i - cocina["usedSpace"].to_i
  end

  '''Maneja las respuestas de fabricarSinPago'''
  def handle_response(respuesta, ingrediente, quantity, to)
    if respuesta["error"]
      if respuesta["error"] == "No existen suficientes materias primas"
        puts "No existen suficientes materias primas".red
        if respuesta["detalles"]
          if respuesta["detalles"].length > 0
            for detalle in respuesta["detalles"]
              sku = detalle[0]["sku"].to_i
              producto = Product.find_by sku: sku
              cantidad = detalle[0]["requerido"].to_i - detalle[0]["disponible"].to_i
              if producto.level == 1
                lot = production_lot(producto, cantidad*2)
                fabricar = fabricarSinPago(@@api_key, producto, lot)
              else
                fabricar_producto(cantidad*2, producto, 'despacho')
              end
            end
          else
            producto = Product.find_by sku: ingrediente.to_i
            if producto.level == 1
              lot = production_lot(producto, quantity*2)
              fabricar = fabricarSinPago(@@api_key, producto, lot)
            else
                fabricar_producto(quantity*2, ingrediente.to_i, 'despacho')
            end
          end
        else
          producto = Product.find_by sku: ingrediente.to_i
          if producto.level == 1
            lot = production_lot(producto, quantity*2)
            fabricar = fabricarSinPago(@@api_key, producto, lot)
          else
              fabricar_producto(quantity*2, ingrediente.to_i, 'despacho')
          end
        end
      end
      if respuesta["error"].include? "sku no"
        puts "sku no encontrado".red
        pedir_otro_grupo_oc(ingrediente, quantity)
        '''OJO MANEJAR LA RESPUESTA DE OTRO GRUPO'''
      end
      if respuesta["error"].include? "Lote incorrecto"
        puts "Lote incorrecto".red
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
    total = 0
    contador = 0
    inventario = get_dict_inventories()
    for ingrediente in ingredientes
      '''3.1 Cuanto necesito de cada ingrediente'''
      '''3.1.1 Buscar la cantidad'''
      puts "Revisando Ingrediente -> #{ingrediente}".yellow
      ingredient = Ingredient.find_by(sku_product: sku, sku_ingredient: ingrediente)
      '''3.1.2 Reviso el stock que tengo de ese producto'''
      '''Si tengo el stock ahora'''
      revisado = false
      lot = production_lot_ingredient(sku, ingrediente, cantidad)
      real = inventario[ingrediente] ? inventario[ingrediente] : 0
      if real >= lot
        revisado = true
        contador = contador + 1
        total += lot
      end
      '''Si el producto no está en stock o hay que pedirlo'''
      if !revisado
        puts "No teníamos stock de #{ingrediente}, enviando a producir...".red
        lot = production_lot(ingrediente, cantidad)
        fabricar = fabricarSinPago(@@api_key, ingrediente.to_s, lot*2)
        respuesta = JSON.parse(fabricar.body)
        handle_response(respuesta, ingrediente, lot, 'recepcion')
      else
        puts "  Ingrediente #{ingrediente} tenía stock".magenta
      end
    end
    return contador == total_ingredientes.to_i, total
  end

  def move_ingredientes(sku, cantidad, ingredientes, to)
    for ingrediente in ingredientes
      lot = production_lot_ingredient(sku, ingrediente ,cantidad)
      puts "Moviendo ingrediente #{ingrediente} cantidad #{lot} a #{to}".blue
      @@using_despacho = true
      if to == 'despacho'
        move_q_products_almacen(@@pulmon, @@despacho, ingrediente.to_s, lot)
      elsif to == 'cocina'
        move_q_products_almacen(@@pulmon, @@cocina, ingrediente.to_s, lot)
      end
    end
  end

  def execute_ftp
    '''1. Veo las ordenes que me llegan '''
    ordenes1 = ordenes_segunda_oportundidad()
    ordenes2 = get_ftp()
    ordenes = ordenes1 + ordenes2
    for orden in ordenes
      evaluacion = false
      if orden["canal"] == "b2b"
        '''No hago nada'''
      else
        sku = orden["sku"]
        cantidad = orden["cantidad"]
        '''2. Por casa orden, evaluo si puedo producir el producto'''
        evaluacion = evaluar_fabricar_final(cantidad, sku)
        if evaluacion
          '''Notificar aceptacion'''
          '''3. Mando a fabricar el producto, si es que la evaluacion es positiva'''
          respuesta = fabricar_final(cantidad, sku)
          '''3.1 Si hay un error en la fabricación'''
          '''Esto NOOO deberia pasar'''
          if respuesta["error"]
            #rechazar_oc(orden["_id"])
            @@ordenes_no_rechazadas << orden["_id"]
          '''3.2 Si va todo bien en la fabricacion'''
          else
            '''3.2.1 Recepciono la orden'''
            '''ESTO DEBERIA PASAR POCO'''
            recepcionar_oc(orden["_id"])
            '''3.2.2 Agrego la orden a pendientes'''
            order = PendingOrder.new
            order[:id_oc] = orden["_id"]
            order[:reception_date] = Time.now
            order[:max_dispatch_date] = orden["fechaEntrega"]
            order.save
          end
        '''4. Si la evaluacion es negativa, rechazo la orden'''
        else
          '''Notificar rechazo'''
          #rechazar_oc(orden["_id"])
          @@ordenes_no_rechazadas << orden["_id"]
        end
      end
    end
  end


end
