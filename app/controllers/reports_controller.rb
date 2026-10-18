class ReportsController < ApplicationController
  before_action :authenticate_user!
  include ReportsHelper

  def index

  end

  ##############################################################################
  # Note: Any methods other than index that appear in this class should be     #
  # defined in alphabetical order below.                                       #
  ##############################################################################

  # GET /reports/address_list
  # POST /reports/address_list
  def address_list
    respond_to do |format|
      format.csv do
        send_csv address_list_csv(report_selection(:address_list))
      end
    end
  end

  # GET /reports/email_list
  # POST /reports/email_list
  def email_list
    render plain: email_list_string(report_selection(:email_list))
  end

  # GET /reports/:report/filters/members
  def filter_members
    return head :not_found unless Reports::Definition.exists?(params[:report])

    report = Reports::Definition.find(params[:report])
    return head :not_found unless report.filters.include?(:members)

    query = params.fetch(:q, {}).permit(*report.permitted_params)
    render partial: 'reports/member_options', locals: { people: member_filter_people(query), selected_ids: [] }
  end

  # GET /reports/:report/filters
  def filters
    return head :not_found unless Reports::Definition.exists?(params[:report])

    render partial: 'reports/filter_modal_content', locals: { report: Reports::Definition.find(params[:report]) }
  end

  # GET /reports/member_directory
  # POST /reports/member_directory
  # Essentially a dump of (almost) all member info in the database
  def member_directory
    respond_to do |format|
      format.csv do
        send_csv member_directory_csv(report_selection(:member_directory))
      end
    end
  end

  # GET /reports/member_list
  # POST /reports/member_list
  def member_list
    # @query = params[:q] || {}
    # @query.merge! active?: true
    respond_to do |format|
      selection = report_selection(:member_list)
      @q = selection.search
      @people = selection.result

      format.html do
        # current_membership_periods = MembershipPeriod.where(%Q{effective_date < '#{Date.today}' AND expiration_date > '#{Date.today}'})
        # current_memberships = Membership.joins(:membership_records).where(membership_period_id: current_membership_periods)
        # @people = Person.joins(:memberships).where('memberships_people.membership_id' => current_memberships)
      end

      format.csv do
        send_csv member_list_csv(@people)
      end
    end
  end

  # GET /reports/membership_cards
  # POST /reports/membership_cards
  def membership_cards
    @people = report_selection(:membership_cards).result
    respond_to do |format|
      format.html { render template: 'reports/membership_cards', layout: false }
    end
  end

  private

  def report_selection(key)
    report = Reports::Definition.find(key)
    query  = params.fetch(:q, {}).permit(*report.permitted_params, :s)
    Reports::Selection.new(report.base, query)
  end
end
