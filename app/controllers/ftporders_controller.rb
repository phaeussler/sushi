class FtpordersController < ApplicationController

  # GET /ftporders
  def index
    msg = "FTP"
    render json: msg,   :status => 200
    # puts "RECECPCION"
    # sku_with_stock(@@recepcion, @@api_key)
    # puts "COCINA"
    # sku_with_stock(@@cocina, @@api_key)
    # puts "PULMON"
    # sku_with_stock(@@pulmon, @@api_key)
    # puts "DESPACHO"
    # sku_with_stock(@@despacho, @@api_key)
    create_oc("1005", 1,1)

    #move_q_products_almacen(@@pulmon, @@despacho, "1005", 1)
    #recepcionar_oc("5cee8b0964c02f0004b31c0d")
    # recepcionar_oc("5cee11ac64c02f0004b26c60")
    # move_product_bodega("5cee2ea362883e00047d931a",@@recepcion ,"5cee11ac64c02f0004b26c60", 1)
    rechazar_oc("5cee0ac023b15a000a923b09")



  end


  '''Manejar la respuesta del otro grupo'''
  '''POST a la URL'''
  # POST/ftporders
  def create
    puts "HOLA"
  end




end
