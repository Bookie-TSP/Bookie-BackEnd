class ChaosController < ApplicationController
  before_action :set_chao, only: [:show, :edit, :update, :destroy]

  # GET /chaos
  # GET /chaos.json
  def index
    @chaos = Chao.all
  end

  # GET /chaos/1
  # GET /chaos/1.json
  def show
  end

  # GET /chaos/new
  def new
    @chao = Chao.new
  end

  # GET /chaos/1/edit
  def edit
  end

  # POST /chaos
  # POST /chaos.json
  def create
    @chao = Chao.new(chao_params)

    respond_to do |format|
      if @chao.save
        format.html { redirect_to @chao, notice: 'Chao was successfully created.' }
        format.json { render :show, status: :created, location: @chao }
      else
        format.html { render :new }
        format.json { render json: @chao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chaos/1
  # PATCH/PUT /chaos/1.json
  def update
    respond_to do |format|
      if @chao.update(chao_params)
        format.html { redirect_to @chao, notice: 'Chao was successfully updated.' }
        format.json { render :show, status: :ok, location: @chao }
      else
        format.html { render :edit }
        format.json { render json: @chao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chaos/1
  # DELETE /chaos/1.json
  def destroy
    @chao.destroy
    respond_to do |format|
      format.html { redirect_to chaos_url, notice: 'Chao was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chao
      @chao = Chao.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chao_params
      params[:chao]
    end
end
