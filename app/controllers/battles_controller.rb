class BattlesController < ApplicationController
  def index
    @battles = Battle.all.order(time: :desc).page(params[:page])
  end

  #GET /battles/select_mode
  def select_mode
  end

  #POST /battles/search_mode
  def search_mode
    mode = Mode.find_by(name: params[:select_mode][:mode])
    redirect_to "/battles/#{mode.id}/select_map"
  end

  #GET /battles/:mode_id/select_map
  def select_map
    @mode = Mode.find_by(id: params[:mode_id])
  end

  #POST /battles/:mode_id/search_map
  def search_map
    mode = Mode.find_by(id: params[:mode_id])
    map = Map.find_by(name: params[:select_map][:map])
    event = Event.find_by(mode_id: mode.id, map_id: map.id)
    redirect_to "/battles/select_player?event_id=#{event.id}"
  end

  #GET /battles/select_player
  def select_player
    @event = Event.find_by(id: params[:event_id])
  end

  #POST /battles/select_player
  def search_player
    event = Event.find_by(id: params[:event_id])
    accounts = []
    player1 = Player.find_by(name: params[:select_player][:player1])
    accounts.push(player1.accounts)
    accounts.flatten!
    if params[:select_player][:player2].present?
      player2 = Player.find_by(name: params[:select_player][:player2])
      accounts.push(player2.accounts)
      accounts.flatten!
    end
    if params[:select_player][:player3].present?
      player3 = Player.find_by(name: params[:select_player][:player3])
      accounts.push(player3.accounts)
      accounts.flatten!
    end
    
    # Account.where(id: accounts.map {|account| account.id}).each do |a|
    #   Battle.includes(:picks).where(picks: {id: a.picks.map{|pick| pick.id}})
    #   a.picks.includes(:battles).where(battles: {event_id: event.id})
    # end
    results = []
    accounts.each do |account|
      battles = Battle.includes(:picks).where(event_id: event.id, picks: {account_id: account.id}).to_a
      if results.empty?
        results = battles
      else
        results = results & battles
      end
    end
    @battles = Battle.where(id: results.map{|result| result.id}).order(time: :desc).page(params[:page])
    render :index
  end
end
