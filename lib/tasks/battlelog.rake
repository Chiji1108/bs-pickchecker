require "typhoeus"
require "typhoeus/adapters/faraday"

namespace :battlelog do
  desc "getting battlelogs with api and push the data"
  task get: :environment do
    # ActiveRecord::Base.logger = Logger.new(STDOUT)

    API_URL = "https://api.brawlstars.com/v1/"
    # API_URL = "https://api.starlist.pro/v1/"
    conn = Faraday.new(API_URL) do |builder|
      builder.request :retry, max: 2, interval: 0.5, interval_randomness: 0.5, backoff_factor: 2
      # builder.response :logger

      builder.adapter :typhoeus
      # builder.adapter Faraday.default_adapter
    end
    conn.headers["Accept"] = "application/json"
    conn.headers["authorization"] = ENV['API_TOKEN']
    conn.headers["X-Forwarded-For"] = ENV['API_IP']
    # conn.headers["Authorization"] = ENV['STARLIST_TOKEN']

    responses = {}
    conn.in_parallel do
      Account.where.not(player: nil).each do |account|
        responses["#{account.tag}"] = conn.get("players/%23#{account.tag}/battlelog")
      end
    end
    # Account.where.not(player: nil).each do |account|
    #   responses["#{account.tag}"] = conn.get("player/battlelog?tag=#{account.tag}")
    # end
    responses.each do |k, v|
      if v.success?
        account = Account.find_by(tag: k)
        puts HighLine.new.color(account.player.name, :green)
        json_battlelogs = JSON.parse(v.body)
        json_battlelogs["items"].each.with_index(1) do |json_battlelog, i|
          ActiveRecord::Base.transaction do
            # puts "   --- ( #{i} / #{json_battlelogs["items"].length} ) ---"
            mode = Mode.find_or_create_by(name: json_battlelog["event"]["mode"])
            map = Map.find_or_create_by(name: json_battlelog["event"]["map"])
            event = Event.find_or_create_by(bs_id: json_battlelog["event"]["id"], mode_id: mode.id, map_id: map.id)
            if json_battlelog["battle"]["type"].present?
              battle_type = BattleType.find_or_create_by(name: json_battlelog["battle"]["type"])
            else
              battle_type = BattleType.find_or_create_by(name: "other")
            end

            json_battleTime = json_battlelog["battleTime"]
            /\./ =~ json_battleTime
            date = /T/.match($`).pre_match
            /\./ =~ json_battleTime
            time = /T/.match($`).post_match
            /\./ =~ json_battleTime
            json_time_code = $'
            datetime = Time.utc(date.slice(0,4),date.slice(4,2),date.slice(6,2),time.slice(0,2),time.slice(2,2),time.slice(4,2))

            battle = Battle.find_by({
              event_id: event.id,
              battle_type_id: battle_type.id,
              time: datetime,
              time_code: json_time_code,
              duration: json_battlelog["battle"]["duration"]
            })
            unless battle.nil?
              unless AccessHistory.exists?(account_id: account.id, battle_id: battle.id)
                AccessHistory.create(account_id: account.id, battle_id: battle.id)
                team = battle.team_with(account)
                team.update(result: json_battlelog["battle"]["result"])
                team.update(rank: json_battlelog["battle"]["rank"])
                pick = battle.pick_with(account)
                pick.update(trophy_change: json_battlelog["battle"]["trophyChange"])
              end
              next
            end

            # puts "new Battle (#{i} / #{json_battlelogs["items"].length})"
            battle = Battle.create!({
              event_id: event.id,
              battle_type_id: battle_type.id,
              time: datetime,
              time_code: json_time_code,
              duration: json_battlelog["battle"]["duration"]
            })
            # puts "new AccessHistory"
            AccessHistory.create(account_id: account.id, battle_id: battle.id)
            
            # 3vs3 and DUO
            if json_battlelog["battle"]["teams"].present?
              json_battlelog["battle"]["teams"].each.with_index(1) do |json_team, i2|
                team = Team.create
                # puts "new Team (#{i2} / #{json_battlelog["battle"]["teams"].length})"
                ActiveRecord::Base.transaction do
                  json_team.each.with_index(1) do |json_pick, i3|
                    # puts " new Pick (#{i3} / #{json_team.length})"
                    json_tag = json_pick["tag"]
                    json_tag.slice!("#")
            
                    pick_account = Account.find_or_create_by(tag: json_tag)
            
                    profile = Profile.find_or_create_by(account_id: pick_account.id)
                    profile.update(name: json_pick["name"])
            
                    brawler = Brawler.find_or_create_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])
            
                    pick = Pick.create!(
                      battle_id: battle.id,
                      team_id: team.id,
                      account_id: pick_account.id,
                      brawler_id: brawler.id,
                      power: json_pick["brawler"]["power"],
                      trophies: json_pick["brawler"]["trophies"]
                    )

                    if json_battlelog["battle"]["rank"].present?
                      team.update!(rank: i2)
                      # puts "#{team.rank}"
                    end
                    if pick_account.tag == account.tag
                      pick.update!(trophy_change: json_battlelog["battle"]["trophyChange"])
                      team.update!(result: json_battlelog["battle"]["result"])
                      # puts "#{team.result}"
                      team.update!(rank: json_battlelog["battle"]["rank"])
                      # puts "#{team.rank}"
                    end
                    if json_battlelog["battle"]["starPlayer"].present?
                      json_star_player_tag = json_battlelog["battle"]["starPlayer"]["tag"]
                      json_star_player_tag.slice!("#")
                      if pick_account.tag == json_star_player_tag
                        pick.update!(is_mvp: true)
                      else
                        pick.update!(is_mvp: false)
                      end
                    end

                    # puts HighLine.new.color(" ↓↓↓↓↓", :red)
                    # puts "  Picks count: #{Pick.count}"
                    # puts "  Pick ID: #{pick.id}"
                    # puts "  Pick Team ID: #{pick.team.id}"
                    # puts "  Pick Battle ID: #{pick.battle.id}"
                    # puts "  Teams count: #{Team.count}"
                    # puts HighLine.new.color(" ↑↑↑↑↑", :red)
                  end
                end
              end
          
              teams = battle.teams_opponent_with(account)
              if teams.length == 1
                if json_battlelog["battle"]["result"] == "defeat"
                  teams.first.update(result: "victory")

                elsif json_battlelog["battle"]["result"] == "victory"
                  teams.first.update(result: "defeat")
                end
              end
            # soloFFA except bigGame
            elsif json_battlelog["battle"]["players"].present? && json_battlelog["battle"]["bigBrawler"].blank?
              json_battlelog["battle"]["players"].each.with_index(1) do |json_pick, i2|
                team = Team.create
                # puts "new Team & Pick (#{i2} / #{json_battlelog["battle"]["players"].length})"
                json_tag = json_pick["tag"]
                json_tag.slice!("#")
        
                pick_account = Account.find_or_create_by(tag: json_tag)
        
                profile = Profile.find_or_create_by(account_id: pick_account.id)
                profile.update(name: json_pick["name"])
        
                brawler = Brawler.find_or_create_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])
        
                # pick_id = Pick.count
                # puts "  Picks count: #{Pick.count}"
                pick = Pick.create!({
                  # id: pick_id+1,
                  battle_id: battle.id,
                  team_id: team.id,
                  account_id: pick_account.id,
                  brawler_id: brawler.id,
                  power: json_pick["brawler"]["power"],
                  trophies: json_pick["brawler"]["trophies"]
                })
                # puts "  Picks count: #{Pick.count}"
        
                if json_battlelog["battle"]["rank"].present?
                  team.update(rank: i2)
                end
                if pick_account.tag == account.tag
                  pick.update(trophy_change: json_battlelog["battle"]["trophyChange"])
                  team.update(result: json_battlelog["battle"]["result"])
                  team.update(rank: json_battlelog["battle"]["rank"])
                end
                if json_battlelog["battle"]["starPlayer"].present?
                  json_star_player_tag = json_battlelog["battle"]["starPlayer"]["tag"]
                  json_star_player_tag.slice!("#")
                  if pick_account.tag == json_star_player_tag
                    pick.update(is_mvp: true)
                  else
                    pick.update(is_mvp: false)
                  end
                end
                
                # puts HighLine.new.color(" ↓↓↓↓↓", :green)
                # puts "  Picks count: #{Pick.count}"
                # puts "  Pick ID: #{pick.id}"
                # puts "  Pick Team ID: #{pick.team.id}"
                # puts "  Pick Battle ID: #{pick.battle.id}"
                # puts "  Teams count: #{Team.count}"
                # puts HighLine.new.color(" ↑↑↑↑↑", :green)
              end
          
              teams = battle.teams_opponent_with(account)
              if teams.length == 1
                if json_battlelog["battle"]["result"] == "defeat"
                  teams.first.update(result: "victory")
                elsif json_battlelog["battle"]["result"] == "victory"
                  teams.first.update(result: "defeat")
                end
              end
            # PvE
            # 1vs6 新モード
            end
          end
        end
      else
        puts HighLine.new.color("#{k}がエラー -> code: #{v.status}", :red)
      end
    end
  end
end
