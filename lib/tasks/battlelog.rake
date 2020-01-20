require "typhoeus"
require "typhoeus/adapters/faraday"

namespace :battlelog do
  desc "getting battlelogs with api and push the data"
  task get_battlelogs: :environment do
    

    API_URL = "https://api.brawlstars.com/v1/"
    conn = Faraday.new(url: API_URL) do |builder|
      builder.adapter :typhoeus
    end
    conn.headers["Accept"] = "application/json"
    conn.headers["authorization"] = ENV['API_TOKEN']
    conn.headers["X-Forwarded-For"] = ENV['API_IP']

    responses = {}
    conn.in_parallel do
      Account.where.not(player: nil).each do |account|
        responses["#{account.tag}"] = conn.get("/players/%23#{account.tag}/battlelog")
      end
    end
    responses.each do |k, v|
      if v.success?
        account = Account.find_by(tag: k)
        json_battlelogs = JSON.parse(v.body)
        json_battlelogs["items"].each do |json_battlelog|
          json_mode = json_battlelog["event"]["mode"]
          mode = {name: json_mode}
          Mode.create(mode)
          map = {name: json_battlelog["event"]["map"]}
          Map.create(map)
          event = {id: json_battlelog["event"]["id"], mode_id: Mode.find_by(mode).id, map_id: Map.find_by(map).id}
          Event.create(event)
          battle_type = {name: json_battlelog["battle"]["type"]}
          BattleType.create(battle_type)

          json_battleTime = json_battlelog["battleTime"]
          /¥./ =~ json_battleTime
          date = /T/.match($`).pre_match
          /¥./ =~ json_battleTime
          time = /T/.match($`).post_match
          Time.utc(date.slice(0,4),date.slice(4,2),date.slice(6,2),time.slice(0,2),time.slice(2,2),time.slice(4,2))

          battle = {event_id: Event.find_by(event), battle_type_id: BattleType.find_by(battle_type), time: Time.utc(date.slice(0,4),date.slice(4,2),date.slice(6,2),time.slice(0,2),time.slice(2,2),time.slice(4,2)), duration: json_battlelog["battle"]["duration"]}
          Battle.create(battle)
          json_battlelog["battle"]["teams"].each do |json_team|
            json_team.each do |json_pick|
              brawler = {bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"]} 
              Brawler.create(brawler)
              Team.all.each do |t|
                t.picks
              end
            end
          end
        end
      else
        puts "#{k}がエラー"
      end
    end
    # def get_battlelogs_from_api(tag)
    #   connection = Faraday.new("https://api.brawlstars.com/v1/players/%23#{tag}/battlelog")
    #   connection.headers["Accept"] = "application/json"
    #   connection.headers["authorization"] = ENV['API_TOKEN']
    #   connection.headers["X-Forwarded-For"] = ENV['API_IP']
    #   response = connection.get
    #   if response.success?
    #     JSON.parse(response.body)
    #   else
    #     case response.status
    #     when 400
    #       flash[:alert] = "#{response.reason_phrase}: Client provided incorrect parameters for the request."
    #     when 403
    #       flash[:alert] = "#{response.reason_phrase}: Access denied, either because of missing/incorrect credentials or used API token does not grant access to the requested resource."
    #     when 404
    #       flash[:alert] = "#{response.reason_phrase}: Resource was not found."
    #     when 429
    #       flash[:alert] = "#{response.reason_phrase}: Request was throttled, because amount of requests was above the threshold defined for the used API token."
    #     when 500
    #       flash[:alert] = "#{response.reason_phrase}: Unknown error happened when handling the request."
    #     when 503
    #       flash[:alert] = "#{response.reason_phrase}: Service is temprorarily unavailable because of maintenance."
    #     else
    #       flash[:alert] = "#{response.reason_phrase}: その他のエラーが発生しました。"
    #     end
    #     nil
    #   end
    # end

    # def update_battlelogs(account)
    #   hash = get_battlelogs_from_api(account.tag)
    #   if hash
    #     profile = account.profile
    #     unless profile
    #       profile = Profile.new(account_id: account.id)
    #     end
    #     profile.name = hash["name"]
    #     profile.highestTrophies = hash["highestTrophies"]
    #     profile.highestPowerPlayPoints = hash["highestPowerPlayPoints"]
    #     profile.isQualifiedFromChampionshipChallenge = hash["isQualifiedFromChampionshipChallenge"]
    #     profile.threeVsThreeVictories = hash["3vs3Victories"]
    #     profile.save
    #   end
    # end
  end
end
