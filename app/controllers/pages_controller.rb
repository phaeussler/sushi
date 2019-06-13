class PagesController < ApplicationController
  def home
    puts "HOME"
    if @@first_execution
      puts "YA SE EJECUTO"
    else
      @@first_execution = true
      handler = Handler.new
      # handler.empty_reception
      # handler.check_inventory
      # handler.ordenes_de_compra_ftp
      # handler.oc_pendientes
      handler.satisfy_inventory_level1_job
      handler.satisfy_inventory_level2_job
    end
  end

end
