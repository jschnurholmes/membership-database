class Api::V1::MembershipsController < ApplicationController
  respond_to :json

  # GET    /api/v1/memberships
  def index
  end

  # POST   /api/v1/memberships
  def create

  end

  # GET    /api/v1/memberships/:id
  def show
    @membership = Membership.find(params.require(:id))
  end

  # PUT    /api/v1/memberships/:id
  def update
    @membership = Membership.find(params.require(:id))
  end

  # DELETE /api/v1/memberships/:id
  def destroy
    @membership = Membership.find(params.require(:id))
    
  end
end
