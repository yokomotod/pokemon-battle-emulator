# :coding : UTF-8

require './pokemon-zukan.rb'

$zukan = PokemonZukan.new

# pokemon = $zukan.pokemon('フシギダネ')
# enemy = $zukan.pokemon('ヒトカゲ')

# pokemon =  $zukan.pokemon('フシギバナ', 50, [
#                                              'はっぱカッター',
#                                              'はなびらのまい',
#                                              'こうごうせい',
#                                              'じしん'])
# pokemon = $zukan.pokemon('ミュウツー', 100)
# pokemon = $zukan.pokemon('ミュウツー', 100, [
#                                              'サイコブレイク',
#                                              'はどうだん',
#                                              'れいとうビーム',
#                                              # 'シャドーボール',
#                                              'めいそう',
#                                             ])
pokemon = $zukan.pokemon('アーボック', 100)
enemy =  $zukan.pokemon('リザードン', 100)

loop do
  printf "%s Lv%d\n", pokemon['name'], pokemon['level']
  printf " HP:%d／%d\n", pokemon['hp'], pokemon['max_hp']
  printf "%s Lv%d\n", enemy['name'], enemy['level']
  printf " HP:%d／%d\n", enemy['hp'], enemy['max_hp']

  puts
  printf "%sは どうする？\n", pokemon['name']

  pokemon['skill'].each_with_index do |skill, i|
    printf "%d : %s PP %d／%d わざタイプ／%s \n",
    i, skill['name'], skill['pp'], skill['max_pp'], skill['type']
  end

  print '> '
  input = gets.to_i
  puts

  action = pokemon['skill'][input]['name']

  enemy_decision = $zukan.make_decision(enemy, pokemon)
  enemy_action = enemy['skill'][enemy_decision]['name']

  printf "%sの %s！\n", pokemon['name'], action
  $zukan.skill_proc(pokemon, enemy, action)
  pokemon['skill'][input]['pp'] -= 1
  if enemy['hp'] <= 0
    puts '------------------------------'
    printf "あいての %sは たおれた！\n", enemy['name']
    break;
  end


  printf "あいての %sの %s！\n", enemy['name'], enemy_action
  $zukan.skill_proc(enemy, pokemon, enemy_action)
  enemy['skill'][enemy_decision]['pp'] -= 1
  if pokemon['hp'] <= 0
    puts '------------------------------'
    printf "%s はたおれた！\n", pokemon['name']
    break;
  end


  puts '------------------------------'

end

