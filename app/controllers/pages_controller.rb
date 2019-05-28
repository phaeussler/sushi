class PagesController < ApplicationController
  def home
    puts "HOME"
    ftp = Ftp.new
    ftp.execute
    # if @@first_execution
    #   puts "YA SE EJECUTO"
    # else
    #   @@first_execution = true
    #   handler = Handler.new
    #   handler.empty_reception
    #   handler.check_inventory
    #   handler.ordenes_de_compra_ftp
    # end
  end

end
