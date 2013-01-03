class ResourcesController < ApplicationController
  def index
    @resources = Resource.all
  end

  def create
    @resource = Resource.new(params[:resource])
    @resource.reg_exp = "#{@resource.keyword}:(?:\s*)((\d|[.])+)(?:\s*)"
    @resource.name = @resource.keyword

    @resource.save

    redirect_to :back
  end

  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end
end
