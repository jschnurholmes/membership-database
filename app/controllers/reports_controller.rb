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
  def address_list
    respond_to do |format|
      format.csv do
        send_data address_list_csv
      end
    end
  end

  # GET /reports/email_list
  def email_list
    render plain: email_list_string
  end

  # GET /reports/member_directory
  # Essentially a dump of (almost) all member info in the database
  def member_directory
    respond_to do |format|
      format.csv do
        send_data member_directory_csv
      end
    end
  end

  # GET /reports/member_list
  def member_list
    # @query = params[:q] || {}
    # @query.merge! active?: true
    respond_to do |format|
      defaults = { without_tags: ['banned', 'deceased'] }
      @q = Person.ransack(defaults.merge(params[:q].to_h.symbolize_keys))
      @people = @q.result

      format.html do
        # current_membership_periods = MembershipPeriod.where(%Q{effective_date < '#{Date.today}' AND expiration_date > '#{Date.today}'})
        # current_memberships = Membership.joins(:membership_records).where(membership_period_id: current_membership_periods)
        # @people = Person.joins(:memberships).where('memberships_people.membership_id' => current_memberships)
      end

      format.csv do
        send_data member_list_csv(@people)
      end
    end
  end

  # GET /reports/membership_cards
  # POST /reports/membership_cards
  def membership_cards
    Rails.logger.info params.inspect

    if params.include?(:members)
      Rails.logger.info("Filtering on members")
      @people = Person.where(id: params[:members])
    elsif params.include?(:effective_date)
      Rails.logger.info("Filtering on date")
      @people = Person.all
      effective_date = Date.parse(params[:effective_date])
      Rails.logger.warn("Effective date: #{effective_date}")
      @people = @people.select{|p| p.active?(effective_date) }
    else
      Rails.logger.info("Including all current members")
      @people = Person.all #where(latest_card_number: 0)
      @people = @people.select{|p| p.active? }
    end
    respond_to do |format|
      format.html { render template: 'reports/membership_cards', layout: false }
    end
  end
end
