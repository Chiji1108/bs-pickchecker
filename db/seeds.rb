# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
player = Player.create_or_find_by(name: "Miri")
Account.create_or_find_by(tag: "2089R0RG2", note: "メインアカウント", player_id: player.id)