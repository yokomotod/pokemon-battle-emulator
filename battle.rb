# :coding : UTF-8

require './pokemon-zukan.rb'

$zukan = PokemonZukan.new

def act (pokemon, enemy, decision)
  skill = pokemon['skill'][decision]['name']
  printf "%sの %s！\n", pokemon['name'], skill
  $zukan.skill_proc(pokemon, enemy, skill)
  pokemon['skill'][decision]['pp'] -= 1
end

def act_enemy (enemy, pokemon, enemy_decision)
  skill = enemy['skill'][enemy_decision]['name']
  printf "あいての %sの %s！\n", enemy['name'], skill
  $zukan.skill_proc(enemy, pokemon, skill)
  enemy['skill'][enemy_decision]['pp'] -= 1
end

def gameover?(pokemon, enemy)
  if pokemon['hp'] <= 0
    puts '------------------------------'
    printf "%s はたおれた！\n", pokemon['name']
    return true
  elsif enemy['hp'] <= 0
    puts '------------------------------'
    printf "あいての %sは たおれた！\n", enemy['name']
    return true
  else
    return false
  end
end
# pokemon = $zukan.pokemon('フシギダネ')
# enemy = $zukan.pokemon('ヒトカゲ')

pokemon =  $zukan.pokemon('フシギバナ', 100)
# pokemon =  $zukan.pokemon('フシギバナ', 50, [
#                                              'はっぱカッター',
#                                              'はなびらのまい',
#                                              'こうごうせい',
#                                              'じしん'])
# pokemon = $zukan.pokemon('アルセウス', 100)
# pokemon = $zukan.pokemon('ミュウツー', 100, [
#                                              'サイコブレイク',
#                                              'はどうだん',
#                                              'れいとうビーム',
#                                              # 'シャドーボール',
#                                              'めいそう',
#                                             ])
# pokemon = $zukan.pokemon('レックウザ', 75)
# pokemon =  $zukan.pokemon('リザードン', 100)
enemy =  $zukan.pokemon('リザードン', 100)
# enemy =  $zukan.pokemon('ミュウツー', 100)

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
  decision = gets.to_i
  puts

  enemy_decision = $zukan.make_decision(enemy, pokemon)

  if $zukan.advance?(pokemon, decision, enemy, enemy_decision)
    act(pokemon, enemy, decision)
    if gameover?(pokemon, enemy)
      break
    end

    act_enemy(enemy, pokemon, enemy_decision)
    if gameover?(pokemon, enemy)
      break
    end
  else
    act_enemy(enemy, pokemon, enemy_decision)
    if gameover?(pokemon, enemy)
      break
    end

    act(pokemon, enemy, decision)
    if gameover?(pokemon, enemy)
      break
    end
  end

  puts '------------------------------'

end

