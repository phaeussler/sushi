class AllInventoriesController < ApplicationController
  before_action :set_all_inventory, only: [:show, :edit, :update, :destroy]

  # GET /all_inventories
  # GET /all_inventories.json
  def index
    @inventories = get_dict_inventories
    puts @inventories
    # @ingredients = Ingredient.all
    @products = Product.all
    @recepcion = get_inventorie_from_cellar('recepcion')
    @pulmon = get_inventorie_from_cellar('pulmon')
    @cocina = get_inventorie_from_cellar('cocina')
    @despacho = get_inventorie_from_cellar('despacho')
  end

  # GET /all_inventories/1
  # GET /all_inventories/1.json
  def show
  end

  # GET /all_inventories/new
  def new
    @all_inventory = AllInventory.new
  end

  # GET /all_inventories/1/edit
  def edit
  end

  # POST /all_inventories
  # POST /all_inventories.json
  def create
    @all_inventory = AllInventory.new(all_inventory_params)

    respond_to do |format|
      if @all_inventory.save
        format.html { redirect_to @all_inventory, notice: 'All inventory was successfully created.' }
        format.json { render :show, status: :created, location: @all_inventory }
      else
        format.html { render :new }
        format.json { render json: @all_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /all_inventories/1
  # PATCH/PUT /all_inventories/1.json
  def update
    respond_to do |format|
      if @all_inventory.update(all_inventory_params)
        format.html { redirect_to @all_inventory, notice: 'All inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @all_inventory }
      else
        format.html { render :edit }
        format.json { render json: @all_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /all_inventories/1
  # DELETE /all_inventories/1.json
  def destroy
    @all_inventory.destroy
    respond_to do |format|
      format.html { redirect_to all_inventories_url, notice: 'All inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_all_inventory
      @all_inventory = AllInventory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def all_inventory_params
      params.fetch(:all_inventory, {})
    end
end
