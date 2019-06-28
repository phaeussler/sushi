class Handler < CheckController

  def empty_reception
    puts "------------- Empty Reception job ------------".green
    contador = 0
    for i in sku_with_stock(@@recepcion, @@api_key)[0]
      lista_productos = request_product(@@recepcion, i["_id"], @@api_key)[0]
      for j in lista_productos
        if contador <= 8
          move_product_almacen(j["_id"], @@despacho)
          move_product_almacen(j["_id"], @@pulmon)
          contador += 1
        end
      end
    end
    self.empty_reception()
  end
  handle_asynchronously :empty_reception, :run_at => Proc.new {1.minutes.from_now}

  def oc_pendientes
    puts "------------- Ordenes Pendientes job ------------".green
    pendientes()
    self.oc_pendientes()
  end
  handle_asynchronously :oc_pendientes, :run_at => Proc.new {10.minutes.from_now}

  def ordenes_de_compra_ftp
    puts "------------- Buscar Ordenes de Compra job ------------".green
    execute_ftp
    self.ordenes_de_compra_ftp
  end
  handle_asynchronously :ordenes_de_compra_ftp, :run_at => Proc.new {3.minutes.from_now}


  
  def satisfy_inventory_urgent_job
    puts "------------- Satisfy Inventory Level 1 urgent ------------".green
    satisfy_inventory_urgent()
    self.satisfy_inventory_urgent_job()
  end
  handle_asynchronously :satisfy_inventory_urgent_job, :run_at => Proc.new {4.minutes.from_now}


  def satisfy_inventory_level1_groups_job
    puts "------------- Satisfy Inventory Level 1 Groups job ------------".green
    satisfy_inventory_level1_groups()
    self.satisfy_inventory_level1_groups_job()
  end
  handle_asynchronously :satisfy_inventory_level1_groups_job, :run_at => Proc.new {4.minutes.from_now}

  def satisfy_inventory_level1_job
    puts "------------- Satisfy Inventory Level job ------------".green
    satisfy_inventory_level1()
    self.satisfy_inventory_level1_job
  end
  handle_asynchronously :satisfy_inventory_level1_job, :run_at => Proc.new {13.minutes.from_now}

  def satisfy_inventory_level2_job
    puts "------------- Satisfy Inventory Level 2 job ------------".green
    satisfy_inventory_level2()
    self.satisfy_inventory_level2_job
  end
  handle_asynchronously :satisfy_inventory_level2_job, :run_at => Proc.new {11.minutes.from_now}

  def arrocero
    puts "------------- Arrocero job ------------".green
    inventories = get_dict_inventories()
    product = Product.find_by sku: 1101
    product2 = Product.find_by sku: 1002
    in_cellar = inventories[product["sku"]] ? inventories[product["sku"]] : 0
    in_cellar2 = inventories[product2["sku"]] ? inventories[product2["sku"]] : 0
    if product["min"]*1.6 >= in_cellar and in_cellar < product["max"]
      fabricar_producto(10, 1101, 'despacho')
    end
    if product2["min"]*0.4 >= in_cellar2 and in_cellar2 < product2["max"]*0.4
      fabricar_producto(10, 1002, 'despacho')
    end
    self.arrocero
  end
handle_asynchronously :arrocero, :run_at => Proc.new {7.minutes.from_now}

  def delete_over_stock_job
    puts "------------- delete_over_stock_job ------------".green
    delete_over_stock()
    self.delete_over_stock_job
  end
  handle_asynchronously :delete_over_stock_job, :run_at => Proc.new {5.minutes.from_now}

end
