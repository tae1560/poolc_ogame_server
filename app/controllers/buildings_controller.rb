class BuildingsController < ApplicationController
  def index
    @buildings = Building.all
  end

  def create
    @building = Building.new(params[:building])
    @building.reg_exp = "#{@building.keyword}(?:\s*)((\d|[.])+)(?:\s*)"
    @building.name = @building.keyword

    @building.save

    redirect_to :back
  end

  def destroy
    @building = Building.find(params[:id])
    @building.destroy

    respond_to do |format|
      format.html { redirect_to buildings_url }
      format.json { head :no_content }
    end
  end
end
