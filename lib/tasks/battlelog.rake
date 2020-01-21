require "typhoeus"
require "typhoeus/adapters/faraday"

namespace :battlelog do
  desc "getting battlelogs with api and push the data"
  task get: :environment do
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
        responses["#{account.tag}"] = conn.get("players/%23#{account.tag}/battlelog")
      end
    end
    responses.each do |k, v|
      if v.success?
        account = Account.find_by(tag: k)
        json_battlelogs = JSON.parse(v.body)
        json_battlelogs["items"].each.with_index(1) do |json_battlelog, i|
          puts "-----------#{i}回目のバトル"
          mode = Mode.find_or_create_by(name: json_battlelog["event"]["mode"])
          map = Map.find_or_create_by(name: json_battlelog["event"]["map"])
          event = Event.find_or_create_by(bs_id: json_battlelog["event"]["id"], mode_id: mode.id, map_id: map.id)
          battle_type = BattleType.find_or_create_by(name: json_battlelog["battle"]["type"])

          json_battleTime = json_battlelog["battleTime"]
          /\./ =~ json_battleTime
          date = /T/.match($`).pre_match
          /\./ =~ json_battleTime
          time = /T/.match($`).post_match
          /\./ =~ json_battleTime
          json_time_code = $'
          datetime = Time.utc(date.slice(0,4),date.slice(4,2),date.slice(6,2),time.slice(0,2),time.slice(2,2),time.slice(4,2))

          
          
          if json_battlelog["battle"]["duration"].present?
            is_battle_exists = Battle.exists?({
              event_id: event.id,
              battle_type_id: battle_type.id,
              time: datetime,
              time_code: json_time_code,
              duration: json_battlelog["battle"]["duration"]
            })
          else
            is_battle_exists = Battle.exists?({
              event_id: event.id,
              battle_type_id: battle_type.id,
              time: datetime,
              time_code: json_time_code
            })
          end

          if is_battle_exists
            puts "バトルが既に存在"
            if json_battlelog["battle"]["duration"].present?
              battle = Battle.find_by({
                event_id: event.id,
                battle_type_id: battle_type.id,
                time: datetime,
                time_code: json_time_code,
                duration: json_battlelog["battle"]["duration"]
              })
            else
              battle = Battle.find_by({
                event_id: event.id,
                battle_type_id: battle_type.id,
                time: datetime,
                time_code: json_time_code
              })
            end
            unless AccessHistory.exists?(account_id: account.id, battle_id: battle.id)
              puts "アカウント別の要素を新規追加"
              AccessHistory.create(account_id: account.id, battle_id: battle.id)
              team = battle.getTeamByAccount(account)
              team.update(result: json_battlelog["battle"]["result"])
              team.update(rank: json_battlelog["battle"]["rank"])
              pick = battle.getPickByAccount(account)
              pick.update(trophy_change: json_battlelog["battle"]["trophyChange"])
            else
              puts "アクセスヒストリーも存在するため何もなし"
            end
          else
            puts "バトルを新規追加"
            if json_battlelog["battle"]["duration"].present?
              battle = Battle.create({
                event_id: event.id,
                battle_type_id: battle_type.id,
                time: datetime,
                time_code: json_time_code,
                duration: json_battlelog["battle"]["duration"]
              })
            else
              battle = Battle.create({
                event_id: event.id,
                battle_type_id: battle_type.id,
                time: datetime,
                time_code: json_time_code
              })
            end
            unless AccessHistory.exists?(account_id: account.id, battle_id: battle.id)
              puts "アクセスヒストリーなども新規追加"
              AccessHistory.create(account_id: account.id, battle_id: battle.id)
              # 3vs3 and DUO
              if json_battlelog["battle"]["teams"].present?
                json_battlelog["battle"]["teams"].each.with_index(1) do |json_team, i|
                  team = Team.create
                  json_team.each do |json_pick|
                    json_tag = json_pick["tag"]
                    json_tag.slice!("#")
            
                    pick_account = Account.find_or_create_by(tag: json_tag)
            
                    profile = Profile.find_or_create_by(account_id: pick_account.id)
                    profile.update(name: json_pick["name"])
            
                    brawler = Brawler.find_or_create_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])
            
                    pick = Pick.create({
                      battle_id: battle.id,
                      team_id: team.id,
                      account_id: pick_account.id,
                      brawler_id: brawler.id,
                      power: json_pick["brawler"]["power"],
                      trophies: json_pick["brawler"]["trophies"]
                    })
            
                    if json_battlelog["battle"]["rank"].present?
                      team.update(rank: i)
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
                  end
                end
            
                teams = battle.getOpponentTeamsByAccount(account)
                if teams.length == 1
                  if json_battlelog["battle"]["result"] == "defeat"
                    teams.first.update(result: "victory")
                  elsif json_battlelog["battle"]["result"] == "victory"
                    teams.first.update(result: "defeat")
                  end
                end
              # soloFFA
              elsif json_battlelog["battle"]["players"].present?
                json_battlelog["battle"]["players"].each.with_index(1) do |json_pick, i|
                  team = Team.create
                  p json_pick
                  p json_pick["tag"]
                  json_tag = json_pick["tag"]
                  json_tag.slice!("#")
          
                  pick_account = Account.find_or_create_by(tag: json_tag)
          
                  profile = Profile.find_or_create_by(account_id: pick_account.id)
                  profile.update(name: json_pick["name"])
          
                  brawler = Brawler.find_or_create_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])
          
                  pick = Pick.create({
                    battle_id: battle.id,
                    team_id: team.id,
                    account_id: pick_account.id,
                    brawler_id: brawler.id,
                    power: json_pick["brawler"]["power"],
                    trophies: json_pick["brawler"]["trophies"]
                  })
          
                  if json_battlelog["battle"]["rank"].present?
                    team.update(rank: i)
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
                end
            
                teams = battle.getOpponentTeamsByAccount(account)
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
        end
      else
        puts "#{k}がエラー"
      end
    end
  end
end
