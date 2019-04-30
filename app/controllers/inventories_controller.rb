

class InventoriesController < ApplicationController
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]
  include InventoriesHelper
  require 'httparty'


  def index
    @inventories = Inventory.all
    secret_key = "RAPrFLl620Cg$o"
    data = "GET"

    hash_almacenes =  hmac_sha1(data, secret_key)
    Rails.logger.debug("HASH: #{hash_almacenes}")
    @almacenes = HTTParty.get('https://integracion-2019-dev.herokuapp.com/bodega/almacenes', 
      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_almacenes}",
        "Content-Type": "application/json"
      })
    Rails.logger.debug("Almacenes: #{@almacenes}")
    puts "INTEGRACION grupo1_____:#{hash_almacenes}}"
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
