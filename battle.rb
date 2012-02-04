# :coding : UTF-8

require './pokemon-zukan.rb'

if ARGV.size != 2
  abort(sprintf "usage : %s your_pokemon enemy_pokemon\n", $0)
end

pokemon_name = ARGV.shift
enemy_name = ARGV.shift

$zukan = PokemonZukan.new

pokemon =  $zukan.pokemon(pokemon_name, 100)
pokemon['player?'] = true

enemy =  $zukan.pokemon(enemy_name, 100)
enemy['player?'] = false

# pokemon = $zukan.pokemon('ミュウツー', 100, [
#                                              'サイコブレイク',
#                                              'はどうだん',
#                                              'れいとうビーム',
#                                              # 'シャドーボール',
#                                              'めいそう',
#                                             ])
# enemy =  $zukan.pokemon('リザードン', 100, [0,0,0,0,0,0], [0,0,0,0,0,0])

$zukan.battle(pokemon, enemy)
