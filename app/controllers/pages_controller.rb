class PagesController < CheckController
  def home
    puts "HOME"
    if @@first_execution
      puts "YA SE EJECUTO"
    else
      @@first_execution = true
      handler = Handler.new
      handler.satisfy_inventory_level1_job
      handler.satisfy_inventory_level2_job
      # handler.satisfy_inventory_level1_groups_job
      # handler.satisfy_inventory_urgent_job
      handler.oc_pendientes
      handler.ordenes_de_compra_ftp
      handler.empty_reception
      handler.arrocero
      # handler.delete_over_stock_job
    end
  end

end
