
class OrdersController < CheckController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  helper_method :order_request, :create_oc
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

  def evaluar_orden_ftp(orden)
    '''Aqui hay que hacer el get OC'''
    puts "Evaluando Orden"
    sku = orden["sku"]
    cantidad = orden["cantidad"].to_i
    '''1. Consultar inventario '''
    inventario = get_inventories
    stock = 0
    for producto in inventario
      if producto[:sku].to_i == sku.to_i
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

    puts "LLEGA ORDEN"
    '''1. Con la Id voy a buscar al FTP'''
    orden = obtener_oc(@id)[0]
    puts orden

    evaluacion = false
    '''2. Evaluar Orden'''
    begin
      sku = orden["sku"]
      cantidad = orden["cantidad"]
      evaluacion = evaluar_fabricar_final(cantidad, sku)
    rescue NoMethodError => e
    end

    if evaluacion
      respuesta = fabricar_final(cantidad, sku)
      if respuesta["error"]
        res = "No es posible la solicitud"
        render json: res, :status => 404
        '''Notificar rechazo'''
        begin
          rechazar_oc(orden["_id"])
        rescue NoMethodError => e
        end
      else
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
          recepcionar_oc(orden["_id"])
          @@ordenes_pendientes << orden
          #despachar_productos_sku(orden)
        rescue NoMethodError => e
        end
      end
   else
     res = "No es posible la solicitud"
     render json: res, :status => 404
     '''Notificar rechazo'''
     begin
       rechazar_oc(orden["_id"])
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


  end
