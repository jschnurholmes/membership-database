class PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person, only: [:show, :edit, :update, :destroy, :qr_code]

  # GET /people
  # GET /people.json
  def index
    @q = Person.ransack(params[:q])
    @pagy, @people = paginate(@q.result.order(:id).preload(:tags, memberships: :membership_periods))
    @active_person_ids = Person.active_on(Organization.today).where(id: @people.map(&:id)).pluck(:id).to_set
  end

  # GET /people/1
  # GET /people/1.json
  def show
  end

  # GET /people/1/qr_code
  # SVG membership card QR code, generated from the person's own card_data.
  def qr_code
    svg = RQRCode::QRCode.new(@person.card_data).as_svg(module_size: 6, standalone: true, use_path: true)
    render body: svg, content_type: 'image/svg+xml'
  end

  # GET /people/new
  def new
    @person = Person.new
    @person.phone_numbers.build
    @person.email_addresses.build
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:first_name, :middle_name, :last_name, :preferred_name,
                                     phone_numbers_attributes: [:person_id, :id, :phone_number,
                                                                :type_id, :primary?, :_destroy],
                                     email_addresses_attributes: [:person_id, :id, :email, :type_id,
                                                                  :primary?, :_destroy],
                                     tags_attributes: [:id, :_destroy])
    end
end
