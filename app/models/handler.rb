class Handler < CheckController

  # def revisar_cocina
  # end

  def oc_pendientes
    pendientes()
    self.oc_pendientes()
  end
  handle_asynchronously :oc_pendientes, :run_at => Proc.new {15.minutes.from_now }


  '''Esto es en el caso que aceptemos ordenes que dejamos pendientes'''
  def ordenes_de_compra_ftp
    puts "REVISANDO ORDENES"
    ftp = Ftp.new
    ftp.execute
    self.ordenes_de_compra_ftp
  end
  handle_asynchronously :ordenes_de_compra_ftp, :run_at => Proc.new {15.minutes.from_now }

  def satisfy_inventory_level1_groups_job
    satisfy_inventory_level1_gropus()
    self.satisfy_inventory_level1_groups_job()
  end
  handle_asynchronously :satisfy_inventory_level1_groups_job, :run_at => Proc.new {1.minutes.from_now }

  def satisfy_inventory_level1_job
    satisfy_inventory_level1()
    self.satisfy_inventory_level1_job
  end
  handle_asynchronously :satisfy_inventory_level1_job, :run_at => Proc.new {30.minutes.from_now }

  def satisfy_inventory_level2_job
    satisfy_inventory_level2()
    self.satisfy_inventory_level2_job
  end
  handle_asynchronously :satisfy_inventory_level2_job, :run_at => Proc.new {15.minutes.from_now }

end
