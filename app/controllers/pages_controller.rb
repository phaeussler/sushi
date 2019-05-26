class PagesController < ApplicationController
  def home
    puts "HOME"
    handler = Handler.new
    # handler.ordenes_de_compra_ftp
    #handler.empty_reception
    #ftp = Ftp.new
    #ftp.execute
  end

end
