# :coding : UTF-8

require './pokemon-zukan.rb'

if ARGV.size != 2
  abort(sprintf "usage : %s your_pokemon enemy_pokemon\n", $0)
end

pokemon_name = ARGV.shift
enemy_name = ARGV.shift

$zukan = PokemonZukan.new

def show_status (pokemon)
  printf "%s Lv%d %s\n", pokemon['name'], pokemon['level'], pokemon['type'].join('／')
  if pokemon['state'].size != 0
    printf " ### %s ###\n", pokemon['state'].keys.map{|x| $zukan.state_str[x] }.join(' ')
  end
  if pokemon['special_state'].size != 0
    printf " ### %s ###\n", pokemon['state_special'].keys.map{|x| $zukan.state_str[x] }.join(' ')
  end
  printf " HP:%d／%d\n", pokemon['hp'], pokemon['max_hp']
  printf " こうげき:%3d ぼうぎょ:%3d とくこう:%3d とくぼう:%3d すばやさ:%3d\n", pokemon['attack'], pokemon['defence'], pokemon['sp_atk'], pokemon['sp_def'], pokemon['speed']
end

def get_input (pokemon)
  printf "%sは どうする？\n", pokemon['name']

  pokemon['skill'].each_with_index do |skill, i|
    printf "%2d : %s PP %d／%d わざタイプ／%s \n",
    i+1, skill['name'], skill['pp'], skill['max_pp'], skill['type']
  end

  loop do
    print '> '
    decision = gets

    if decision !~ /^\d+$/
      next
    end

    decision = decision.to_i - 1

    if decision < 0 || decision >= pokemon['skill'].size
      next
    end

    if pokemon['skill'][decision]['pp'] <= 0
      puts 'PPが たりない'
      next
    end

    return decision
  end
end

def act (pokemon, enemy, decision)
  skill = pokemon['skill'][decision]['name']
  if $zukan.pre_proc(pokemon)
    printf "%sの %s！\n", pokemon['name'], skill
    $zukan.skill_proc(pokemon, enemy, skill)
    pokemon['skill'][decision]['pp'] -= 1
  end

  $zukan.post_proc(pokemon, enemy)
end

def act_enemy (enemy, pokemon, enemy_decision)
  skill = enemy['skill'][enemy_decision]['name']
  if $zukan.pre_proc(enemy)
    printf "あいての %sの %s！\n", enemy['name'], skill
    $zukan.skill_proc(enemy, pokemon, skill)
    enemy['skill'][enemy_decision]['pp'] -= 1
  end

  $zukan.post_proc(enemy, pokemon)
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

pokemon =  $zukan.pokemon(pokemon_name, 100)
enemy =  $zukan.pokemon(enemy_name, 100)

# pokemon = $zukan.pokemon('ミュウツー', 100, [
#                                              'サイコブレイク',
#                                              'はどうだん',
#                                              'れいとうビーム',
#                                              # 'シャドーボール',
#                                              'めいそう',
#                                             ])
# enemy =  $zukan.pokemon('リザードン', 100, [0,0,0,0,0,0], [0,0,0,0,0,0])

loop do

  show_status(pokemon)
  show_status(enemy)

  puts

  sleep(1)

  decision = get_input(pokemon)
  
  puts

  enemy_decision = $zukan.make_decision(enemy, pokemon)

  if $zukan.advance?(pokemon, decision, enemy, enemy_decision)
    act(pokemon, enemy, decision)
    if gameover?(pokemon, enemy)
      break
    end
    
    puts

    act_enemy(enemy, pokemon, enemy_decision)
    if gameover?(pokemon, enemy)
      break
    end

    puts
  else
    act_enemy(enemy, pokemon, enemy_decision)
    if gameover?(pokemon, enemy)
      break
    end

    puts

    act(pokemon, enemy, decision)
    if gameover?(pokemon, enemy)
      break
    end

    puts
  end

  puts '------------------------------'

end

