class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  # GET /accounts.json
  def index 
    @accounts = Account.all.page(params[:page])
  end

  # POST /accounts/search
  def search
    @accounts = Player.find_by(name: params[:player_name]).accounts.page(params[:page])
    render :index
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    update_profile(@account)
    @profile = @account.profile
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    account = Account.find_by(tag: account_params[:tag])
    if account
      account.player_id = Player.find(account_params[:player_id]).id
      account.note = account_params[:note]
      @account = account
    else
      @account = Account.new(account_params)
    end

    respond_to do |format|
      if @account.save
        update_profile(@account)
        
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        update_profile(@account)

        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find_by!(tag: params[:tag])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:tag, :note, :player_id)
    end

    def get_profile_from_api(tag)
      connection = Faraday.new("https://api.brawlstars.com/v1/players/%23#{tag}")
      connection.headers["Accept"] = "application/json"
      connection.headers["authorization"] = ENV['API_TOKEN']
      connection.headers["X-Forwarded-For"] = ENV['API_IP']
      response = connection.get
      if response.success?
        JSON.parse(response.body)
      else
        case response.status
        when 400
          flash[:alert] = "#{response.reason_phrase}: Client provided incorrect parameters for the request."
        when 403
          flash[:alert] = "#{response.reason_phrase}: Access denied, either because of missing/incorrect credentials or used API token does not grant access to the requested resource."
        when 404
          flash[:alert] = "#{response.reason_phrase}: Resource was not found."
        when 429
          flash[:alert] = "#{response.reason_phrase}: Request was throttled, because amount of requests was above the threshold defined for the used API token."
        when 500
          flash[:alert] = "#{response.reason_phrase}: Unknown error happened when handling the request."
        when 503
          flash[:alert] = "#{response.reason_phrase}: Service is temprorarily unavailable because of maintenance."
        else
          flash[:alert] = "#{response.reason_phrase}: その他のエラーが発生しました。"
        end
        nil
      end
    end

    def update_profile(account)
      hash = get_profile_from_api(account.tag)
      if hash
        profile = account.profile
        unless profile
          profile = Profile.new(account_id: account.id)
        end
        profile.name = hash["name"]
        profile.highestTrophies = hash["highestTrophies"]
        profile.highestPowerPlayPoints = hash["highestPowerPlayPoints"]
        profile.isQualifiedFromChampionshipChallenge = hash["isQualifiedFromChampionshipChallenge"]
        profile.threeVsThreeVictories = hash["3vs3Victories"]
        profile.save
      end
    end
end
