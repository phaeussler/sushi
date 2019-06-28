require 'json'
require 'date'

class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy]

  include PurchaseOrdersHelper

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @purchase_orders = PurchaseOrder.all
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
  end

  # GET /purchase_orders/new
  def new
    @order = ShoppingCartOrder.find(params[:order_id])
    @order_items = ShoppingCartOrderItem.where(shopping_cart_order_id: params[:order_id])
    @items_json = get_items_json(@order_items)

    if @order.shopping_cart_order_items.empty?
      redirect_to :controller => :portal, :action => :index
    end


    @purchase_order = PurchaseOrder.new
    @purchase_order.latitude = -33.4991118
    @purchase_order.longitude = -70.6183225
    @purchase_order.proveedor = "5cbd31b7c445af0004739be3"
    
    
    
    @purchase_order.total = @order.subtotal
    @purchase_order.products = @items_json #{3001=> 1}

  end

  # GET /purchase_orders/1/edit
  def edit
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    if @purchase_order.save
      # Generar boleta
      code, body, headers = generar_boleta(@purchase_order.proveedor, @purchase_order.client, @purchase_order.total)
      puts code, body, headers
      puts 'se genero la boleta'
      if code.to_i == 200
        puts "se redirige a pagar"
        boleta_id = body["_id"]
        oc_id = body["oc"]
        purchased_at = DateTime.parse(body["created_at"])
        deadline = purchased_at + 90.minutes
        puts purchased_at&.class
        puts purchased_at
        puts deadline

        @purchase_order.purchased_at  = purchased_at
        @purchase_order.deadline = deadline
        @purchase_order.boleta_id = boleta_id
        @purchase_order.oc_id = oc_id
        @purchase_order.save
        puts "ID  BOLETA _id: #{boleta_id}"

        code2, body2, headers2 = pagar_orden(boleta_id, @purchase_order.id)
        puts 'se realizo el proceso de pago'
      end

    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def success
    reset_session
  end

  def fail
    reset_session
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      params.require(:purchase_order).permit(:client, :latitude, :longitude, :total, :proveedor, :products)
    end
end
