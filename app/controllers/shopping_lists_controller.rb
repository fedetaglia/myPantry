class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: [:show, :edit, :update, :destroy]

  # GET /shopping_lists
  # GET /shopping_lists.json
  def index
    @shopping_lists = current_user.shopping_lists.all
  end

  # GET /shopping_lists/1
  # GET /shopping_lists/1.json
  def show
    @aggregator = JSON.parse(@shopping_list.aggregator)
    shopping_list = JSON.parse(@shopping_list.ingredients)
    @meals = shopping_list['meals']
  end

  # GET /shopping_lists/new
  def new
    @shopping_list_name = params['name']
    @search_parameter = Search.load_search_parameters()
    @shopping_list = current_user.shopping_lists.new
  end

  # GET /shopping_lists/1/edit
  def edit
  end

  # POST /shopping_lists
  # POST /shopping_lists.json
  def create
    @shopping_list = current_user.shopping_lists.new(shopping_list_params)
    @shopping_lists = current_user.shopping_lists.all

    respond_to do |format|
      if @shopping_list.save
        format.html { redirect_to shopping_lists_path, notice: 'Shopping list was successfully created.' }
        format.json {}
      else
        format.html { render action: 'new' }
        format.json { render json: @shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shopping_lists/1
  # PATCH/PUT /shopping_lists/1.json
  def update
    respond_to do |format|
      if @shopping_list.update(shopping_list_params)
        format.html { redirect_to @shopping_list, notice: 'Shopping list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shopping_lists/1
  # DELETE /shopping_lists/1.json
  def destroy
    @shopping_list.destroy
    respond_to do |format|
      format.html { redirect_to shopping_lists_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shopping_list
      @shopping_list = ShoppingList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shopping_list_params
      params.require(:shopping_list).permit(:name, :aggregator, :ingredients, :user_id)
    end
end
