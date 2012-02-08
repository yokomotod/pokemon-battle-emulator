# :coding : UTF-8

require './pokemon-zukan.rb'

if ARGV.size == 1 && ARGV[0] == '-h'
  abort(sprintf "usage : %s [auto_battle]\n", $0)
end

pokemon_name = ARGV.shift
enemy_name = ARGV.shift
if ARGV.size == 3
  auto_battle = true
else
  auto_battle = false
end

$zukan = PokemonZukan.new

player = $zukan.pokemon_master([
                                ['フシギバナ', 100],
                                ['リザードン', 100],
                                ['カメックス', 100]
                               ])
player['player?'] = auto_battle ? false : true

enemy = $zukan.pokemon_master([
                               ['メガニウム', 100],
                               ['バクフーン', 100],
                               ['オーダイル', 100],
                              ])
enemy['player?'] = false

$zukan.battle(player, enemy)
