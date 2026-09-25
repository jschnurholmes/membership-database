class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_membership, only: [:show, :edit, :update, :destroy]

  # GET /memberships
  # GET /memberships.json
  def index
    @q = Membership.ransack(params[:q])
    @memberships = @q.result
    respond_to do |format|
      format.html {render :index}
      format.csv {send_data Membership.to_csv}
    end
  end

  # GET /memberships/1
  # GET /memberships/1.json
  def show
  end

  # GET /memberships/new
  def new
    @membership = Membership.new
    @membership.addresses.build
    @membership.membership_periods << MembershipPeriod.latest
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.json
  def create
    @membership = Membership.new(membership_params)
    @membership.membership_periods << MembershipPeriod.latest

    respond_to do |format|
      if @membership.save
        format.html { redirect_to @membership, notice: 'Membership was successfully created.' }
        format.json { render :show, status: :created, location: @membership }
      else
        format.html { render :new }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /memberships/1/renew
  # POST /memberships/1/renew.json
  def renew
    @membership = Membership.find(params.require(:id))

    respond_to do |format|
      if @membership.renew
        format.html{ redirect_to @membership, notice: "Membership for #{@membership.member_names} is valid for the period #{@membership.membership_periods.latest}" }
        format.json{ render :show, status: :ok, location: @membership }
      else
        format.html{ redirect_to @membership, notice: "Membership could not be renewed" }
        format.json{ render :show, status: :unprocessable_entity, location: @membership }
      end
    end
  end

  # PATCH/PUT /memberships/1
  # PATCH/PUT /memberships/1.json
  def update
    respond_to do |format|
      request_params = membership_params
      # Default to an empty array so we can delete all members from a membership
      # if needed.
      request_params[:member_ids] ||= []
      if @membership.update(request_params)
        format.html { redirect_to @membership, notice: 'Membership was successfully updated.' }
        format.json { render :show, status: :ok, location: @membership }
      else
        format.html { render :edit }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to memberships_url, notice: 'Membership was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def current_and_potential_members
    latest_membership_period = @membership.membership_periods.latest == MembershipPeriod.latest

    Person.all.order(:last_name, :first_name, :middle_name).select do |person|
      if latest_membership_period
        @membership.members.include?(person) ||
            person.memberships.empty? ||
            person.memberships.latest.membership_periods.latest != MembershipPeriod.latest
      else
        !person.active? || @membership.members.include?(person)
      end
    end
  end
  helper_method :current_and_potential_members

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    # Never trust parameters  from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:membership_type_id, :membership_period_id, :mailing_preference_id,
                                         :member_ids => [],
                                         addresses_attributes: [:membership_id, :id, :address_type_id, :line_1,
                                                                :line_2, :city, :state_id, :zip_code, :_destroy])
    end
end
