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
        json_battlelogs["items"].each do |json_battlelog|
          mode = Mode.create_or_find_by(name: json_battlelog["event"]["mode"])
          map = Map.create_or_find_by(name: json_battlelog["event"]["map"])
          event = Event.create_or_find_by(bs_id: json_battlelog["event"]["id"], mode_id: mode.id, map_id: map.id)
          battle_type = BattleType.create_or_find_by(name: json_battlelog["battle"]["type"])

          json_battleTime = json_battlelog["battleTime"]
          /\./ =~ json_battleTime
          date = /T/.match($`).pre_match
          /\./ =~ json_battleTime
          time = /T/.match($`).post_match
          /\./ =~ json_battleTime
          json_time_code = $'
          datetime = Time.utc(date.slice(0,4),date.slice(4,2),date.slice(6,2),time.slice(0,2),time.slice(2,2),time.slice(4,2))

          battle = Battle.new({
            event_id: event.id,
            battle_type_id: battle_type.id,
            time: datetime,
            time_code: json_time_code,
            duration: json_battlelog["battle"]["duration"]
          })
          if battle.save
            # 3vs3 and DUO
            if json_battlelog["battle"]["teams"]
              json_battlelog["battle"]["teams"].each.with_index(1) do |json_team, i|
                team = Team.create
                json_team.each do |json_pick|
                  json_tag = json_pick["tag"]
                  json_tag.slice!("#")

                  pick_account = Account.create_or_find_by(tag: json_tag)

                  profile = Profile.create_or_find_by(account_id: pick_account.id)
                  profile.update(name: json_pick["name"])

                  brawler = Brawler.create_or_find_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])

                  pick = Pick.create({
                    battle_id: battle.id,
                    team_id: team.id,
                    account_id: pick_account.id,
                    brawler_id: brawler.id,
                    power: json_pick["brawler"]["power"],
                    trophies: json_pick["brawler"]["trophies"]
                  })
                  
                  if json_battlelog["battle"]["rank"]
                    team.update(rank: i)
                  end
                  if pick_account.tag == account.tag
                    pick.update(trophy_change: json_battlelog["battle"]["trophyChange"])
                    team.update(result: json_battlelog["battle"]["result"])
                    team.update(rank: json_battlelog["battle"]["rank"])
                  end
                  if json_battlelog["brawler"]["starPlayer"]["tag"]
                    json_star_player_tag = json_battlelog["brawler"]["starPlayer"]["tag"]
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
            elsif json_battlelog["battle"]["players"]
              json_battlelog["battle"]["players"].each.with_index(1) do |json_player, i|
                team = Team.create
                json_player.each do |json_pick|
                  json_tag = json_pick["tag"]
                  json_tag.slice!("#")

                  pick_account = Account.create_or_find_by(tag: json_tag)

                  profile = Profile.create_or_find_by(account_id: pick_account.id)
                  profile.update(name: json_pick["name"])

                  brawler = Brawler.create_or_find_by(bs_id: json_pick["brawler"]["id"], name: json_pick["brawler"]["name"])

                  pick = Pick.create({
                    battle_id: battle.id,
                    team_id: team.id,
                    account_id: pick_account.id,
                    brawler_id: brawler.id,
                    power: json_pick["brawler"]["power"],
                    trophies: json_pick["brawler"]["trophies"]
                  })
                  
                  if json_battlelog["battle"]["rank"]
                    team.update(rank: i)
                  end
                  if pick_account.tag == account.tag
                    pick.update(trophy_change: json_battlelog["battle"]["trophyChange"])
                    team.update(result: json_battlelog["battle"]["result"])
                    team.update(rank: json_battlelog["battle"]["rank"])
                  end
                  if json_battlelog["brawler"]["starPlayer"]["tag"]
                    json_star_player_tag = json_battlelog["brawler"]["starPlayer"]["tag"]
                    json_star_player_tag.slice!("#")
                    if pick_account.tag == json_star_player_tag
                      pick.update(is_mvp: true)
                    else
                      pick.update(is_mvp: false)
                    end
                  end
                end
              end
            # PvE
            # 1vs6 新モード
            end
          end
        end
      else
        puts "#{k}がエラー"
      end
    end
  end
end
