require 'json'

class InventoriesController < ApplicationController
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]
  include InventoriesHelper
  require 'httparty'

  def index
    @inventories = Inventory.all
    #request_product("5cbd3ce444f67600049431b3", "1001", "RAPrFLl620Cg$o")

     # fabricarSinPago("RAPrFLl620Cg$o", "1001", 500 )
     # fabricarSinPago("RAPrFLl620Cg$o", "1008", 500 )
     # fabricarSinPago("RAPrFLl620Cg$o", "1009", 600 )
     # fabricarSinPago("RAPrFLl620Cg$o", "1015", 500 )
     # fabricarSinPago("RAPrFLl620Cg$o", "1016", 800 )
     productos = sku_with_stock(@@cocina,@@api_key)[0]
     respuesta = []
     for p in productos do
       nombre = Product.find_by sku: p["_id"]
       res = {"sku": p["_id"],"nombre": nombre["name"], "total": p["total"]}
       respuesta << res
     end
     render json: respuesta, :status => 200
     puts "_________________-"
     puts respuesta

  end


  # GET /inventories/1
  # GET /inventories/1.json
  def show
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
  end

  # GET /inventories/1/edit
  def edit
  end

  # POST /inventories
  # POST /inventories.json
  def create
    @inventory = Inventory.new(inventory_params)

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: 'Inventory was successfully created.' }
        format.json { render :show, status: :created, location: @inventory }
      else
        format.html { render :new }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: 'Inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory }
      else
        format.html { render :edit }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: 'Inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
      params.fetch(:inventory, {})
    end
end
