class PagesController < CheckController
  def home
    # FIXME: DELETE THIS: joaquin 
    # @@first_execution = true
    puts "HOME"
    if @@first_execution
      puts "YA SE EJECUTO"
    else
      @@first_execution = true
      handler = Handler.new
      handler.satisfy_inventory_level1_job
      handler.satisfy_inventory_level2_job
      #handler.satisfy_inventory_level1_groups_job
      handler.oc_pendientes
      handler.ordenes_de_compra_ftp
      handler.empty_reception
      handler.arrocero
      handler.portal_pendientes
    end
  end

end
