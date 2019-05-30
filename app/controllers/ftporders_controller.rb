class FtpordersController < CheckController

  # GET /ftporders
  def index
    msg = "FTP"
    render json: msg,   :status => 200
    #
#   fabricarSinPago(@@api_key, "1001",20)
#   fabricarSinPago(@@api_key, "1002",20)
#   fabricarSinPago(@@api_key, "1005",20)
#   fabricarSinPago(@@api_key,"1008", 20)
#   fabricarSinPago(@@api_key,"1009", 20)
#   fabricarSinPago(@@api_key,"1090", 30)
#   fabricarSinPago(@@api_key,"1010", 20)
#   fabricarSinPago(@@api_key,"1010", 20)
#   fabricarSinPago(@@api_key,"1015", 20)
#   fabricarSinPago(@@api_key,"1016", 10)
#
# #
# ''' pedir a otros grupos '''
# (1..10).each do |i|
#     pedir_otro_grupo_oc("1002", 10)
#     pedir_otro_grupo_oc("1003", 10)
#     pedir_otro_grupo_oc("1004", 10)
#     pedir_otro_grupo_oc("1006", 10)
#     pedir_otro_grupo_oc("1007", 10)
#     pedir_otro_grupo_oc("1011", 10)
#     pedir_otro_grupo_oc("1012", 10)
#     pedir_otro_grupo_oc("1013", 10)
#     pedir_otro_grupo_oc("1014", 10)
# end


#  despacho_a_pulmon
#     cocina_a_pulmon
productos = sku_with_stock(@@recepcion, @@api_key)[0]
recepcion_a_pulmon(productos)

# '''para producir minimos secundarios '''
#     lista_sku1 = skus_monitorear()
#     lista_sku2 = encontar_minimos(lista_sku1)
#     productos1 = sku_with_stock(@@cocina, @@api_key)[0]
#     @lista_final, @lista_productos = encontrar_incoming(lista_sku2, productos1)
#     puts @lista_productos
#     inventario_minimo(@lista_productos)

  end


  '''Manejar la respuesta del otro grupo'''
  '''POST a la URL'''
  # POST/ftporders
  def create
    puts "HOLA"
  end




end
