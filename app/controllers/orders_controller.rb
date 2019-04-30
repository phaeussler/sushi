class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  helper_method :order_request

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

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    print(order_params)
    respond_to do |format|
      if @order.save
        msg = {:sku => order_params[:sku], :almacenId => order_params[:almacenId], :cantidad => order_params[:cantidad], :grupoProveedor => 1, :aceptado => 0, :despachado => 0}
        format.json  { render :json => msg }
      end
    end
    
    # respond_to do |format|
    #     format.html { redirect_to @order, notice: 'Order was successfully created.' }
    #     format.json { render :show, status: :created, location: @order }
        
    #   else
    #     format.html { render :new }
    #     format.json { render json: @order.errors, status: :unprocessable_entity }
    #   end
    # end
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

  def order_request(g_num, sku, storeId, quantity)
    # g_num : int [1..14]
    uri = "orders?sku=#{sku}almacenId=#{storeId}}&cantidad=#{quantity}}"
    grup_request("post", g_num, uri)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end


    def order_params
      # params.require(:almacenId, :sku, :cantidad)
      params.permit(:almacenId, :sku, :cantidad)
      # params.fetch(:order, {}).permit(:almacenId, :sku, :cantidad)
    end
    # # Never trust parameters from the scary internet, only allow the white list through.
    # def order_params
    #   params.fetch(:order, {})

    # end
end
