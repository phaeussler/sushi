
class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  helper_method :order_request
  require 'securerandom'
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  def evaluar_pedido(cantidad, sku)
    stock = sku_with_stock(@@cocina, @@api_key)[0]
    stock = stock[0]["total"].to_i
    #Encontrar el find by sku
    min = 0
    minimo = MinimumStock.all
    minimo.each do |m|
      if m["sku"] == sku.to_i
        min = m["minimum_stock"]
        break
      end
      end
    cantidad = cantidad.to_i
    if stock - cantidad < min
      return false
    else
      return true
    end
  end

 #Retorna true si el sku es producido por nosotros
  def check_sku(sku)
    listas_sku = []
    productos = Product.all
    productos.each do |product|

    if product["groups"].split(",")[0] == "1"
        listas_sku << product["sku"]
      end
    end
    if  listas_sku.include?(sku.to_i)
      return true
    else
      return false
    end
  end

  def evaluar_orden_ftp(orden)
    '''Aqui hay que hacer el get OC'''
    puts "Evaluando Orden"
    sku = orden["sku"]
    cantidad = orden["cantidad"].to_i
    '''1. Consultar inventario '''
    inventario = get_inventories
    stock = 0
    for producto in inventario
      if producto[:sku] == sku
        stock = producto[:total].to_i
      end
    end
    '''2. Acepto o Rechazo'''
    '''Ojo que acá se puede hacer algo más avanzado como revisar si tengo los ingredientes para fabricar y mandar a fabricar'''
    if stock - cantidad > 0
      return true
    else
      return false
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    @grupo = request.headers["group"]
    @sku = params[:sku]
    @almacenId = params[:almacenId]
    @cantidad = params[:cantidad]
    @id = params[:oc]

    orden = obtener_oc(@id)[0]
    puts orden
    # orden["sku"] = @sku
    # orden["cantidad"] = @cantidad
    #@id = params[:oc]
    puts "LLEGA ORDEN"
    '''1. Con la Id voy a buscar al FTP'''
    #orden = obtener_oc(@id)[0]
    evaluacion = false
    '''2. Evaluar Orden'''
    begin
      evaluacion = evaluar_orden_ftp(orden)
    rescue NoMethodError => e
    end

    if evaluacion
      '''Notificar aceptacion'''
      res = {
        "sku": @sku,
        "cantidad": @cantidad,
        "almacenId": @almacenId,
        "grupoProveedor": 1,
        "aceptado": true,
        "despachado": true
      }
      render json: res, :status => 201
      begin
        recepcionar_oc(orden)
        #despachar_http(@sku, @cantidad, @almacenId)
        despachar_productos_sku(orden)
      rescue NoMethodError => e
      end
   else
     res = "No es posible la solicitud"
     render json: res, :status => 404
     '''Notificar rechazo'''
     begin
       rechazar_oc(orden)
     rescue NoMethodError => e
     end
    end

  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end


    def order_params
      # params.require(:almacenId, :sku, :cantidad)
      params.permit(:almacenId, :sku, :cantidad, :oc)
      # params.fetch(:order, {}).permit(:almacenId, :sku, :cantidad)
    end
    # # Never trust parameters from the scary internet, only allow the white list through.
    # def order_params
    #   params.fetch(:order, {})

    # end


  '''Generar el Id de la orden de compra y retorna la OC completa'''
  def orden_de_compra_id
    id = SecureRandom.hex
    return id
  end

  '''Pedir productos por la casilla ftp a otros grupos'''
  def pedir_productos_ftp(sku, cantidad)
    puts "PIDIENDO PRODUCTO FTP A OTRO GRUPO"

  end

  def create_deliver_date(sku)
    product = Product.find_by sku: sku
    groups = product.groups
    groups = product.groups.split(",")
    return ((Time.now.to_f + 100000) * 1000).to_i
    # if groups.include?("1")
    #   return ((Time.now.to_f + product.expected_time_production_mins/2)*1000).to_i
    # else
    #   return (Time.now.to_f*1000 + (product.expected_time_production_mins*1.2)*1000).to_i
    # end

  end

  '''Crea una oc al servidor'''
  def create_oc(sku, qty, group)
    # Primero debo buscar el id del grupo
    group = "5cc66e378820160004a4c3c9"
    product = Product.find_by sku: sku
    order = {
      "cliente": @@id_oc_prod,
      "proveedor": @@id_oc_dev,
      "sku": sku,
      "fechaEntrega": create_deliver_date(sku) ,
      "cantidad": qty.to_s,
      "precioUnitario": product.sell_price,
      "canal": "b2b",
      "notas": "Probando",
      "urlNotificacion": "http://tuerca1.ing.puc.cl/orders/{_id}/notification"
    }
    request_oc('oc/crear', order)
  end

  end
