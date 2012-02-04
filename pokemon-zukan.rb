# :coding : UTF-8

class PokemonZukan
  attr_reader :state_str

  def initialize
    @state_str = {
      'SLP' => 'ねむり',
      'PSN' => 'どく',
      'PSN2' => 'もうどく',
      'BRN' => 'やけど',
      'FRZ' => 'こおり',
      'PAR' => 'まひ',

      'CONFUSE'   => 'こんらん',
      'CURSE'     => 'のろい',
      'ENCORE'    => 'アンコール',
      'FLINCH'    => 'ひるみ',
      'IDENTIFY'  => 'みやぶる',
      'MEROMERO'  => 'メロメロ',
      'SEED'      => 'やどりぎのタネ',
      'EYE'       => 'こころのめ',
      'LOCKON'    => 'ロックオン',
      'NIGHTMARE' => 'あくむ',
      'TRAPPED'   => 'しめつける',
      'SONG'      => 'ほろびのうた',
      'TAUNT'     => 'ちょうはつ',
      'TORMENT'   => 'いちゃもん',
    }

    @status_str = {
      'attack'  => 'こうげき',
      'defence' => 'ぼうぎょ',
      'sp_atk'  => 'とくこう',
      'sp_def'  => 'とくぼう',
      'speed'   => 'すばやさ',
      'accuracy' => 'めいちゅう',
      'evasion' => 'かいひ',
    }
    @rank_effect = {
      -6 => 2.0/8.0,
      -5 => 2.0/7.0,
      -4 => 2.0/6.0,
      -3 => 2.0/5.0,
      -2 => 2.0/4.0,
      -1 => 2.0/3.0,
      0 => 1.0,
      1 => 3.0/2.0,
      2 => 4.0/2.0,
      3 => 5.0/2.0,
      4 => 6.0/2.0,
      5 => 7.0/2.0,
      6 => 8.0/2.0,
    }

    @rank_effect_accuracy = {
      -6 => 3.0/9.0,
      -5 => 3.0/8.0,
      -4 => 3.0/7.0,
      -3 => 3.0/6.0,
      -2 => 3.0/5.0,
      -1 => 3.0/4.0,
      0 => 1.0,
      1 => 4.0/3.0,
      2 => 5.0/3.0,
      3 => 6.0/3.0,
      4 => 7.0/3.0,
      5 => 8.0/3.0,
      6 => 9.0/3.0,
    }
     
    @rank_effect_critical = {
      0 => 1.0/16.0,
      1 => 1.0/8.0,
      2 => 1.0/4.0,
      3 => 1.0/3.0,
      4 => 1.0/2.0,
    }

    @state_message = { 
      'SLP_START'    => 'は ねむってしまった',
      'SLP_CONTINUE' => 'は ねむっている',
      'SLP_END'      => 'は めを さました',

      'PSN_START'    => 'は どくを うけた',
      'PSN_CONTINUE' => 'は どくによる ダメージをうけた',

      'PSN2_START'    => 'は もうどくを うけた',

      'BRN_START'    => 'は やけどを おった',
      'BRN_CONTINUE' => 'は やけどによる ダメージをうけた',

      'FRZ_START'    => 'は こおりついた',
      'FRZ_CONTINUE' => 'は こおってしまって うごけない',
      'FRZ_END'      => 'の こおりが とけた',

      'PAR_START'    => 'は まひして わざが でにくくなった',
      'PAR_CONTINUE' => 'は からだが しびれて うごけない',
      'PAR_END'      => 'の しびれが とれた',
    }

    @type_effect = Hash.new
    load_type_effect

    @skill_info = Hash.new
    load_skill

    @pokemon_info = Hash.new
    load_pokemon_status
    load_pokemon_skill
  end

  def load_type_effect
    File.open('data/type_effect.dat', 'r:UTF-8') do |file|
      file.each_line do |line|
        skill_type, target_type, weight = line.chomp.split("\t")

        if !@type_effect.has_key?(skill_type)
          @type_effect[skill_type] = Hash.new
        end

        @type_effect[skill_type][target_type] = weight.to_f
      end
    end
  end

  def load_skill
    File.open('data/waza.csv', 'r:Shift_JIS:UTF-8') do |file|
      header = file.gets

      file.each_line do |line|
        name, power, accuracy, pp, type, category, direct, range, priority, effect_code_data, comment = line.chomp.split(',')

        effect_code_data =~ /(....)(\((\d+)％\))?/
        effect_code = $1
        state_effect_p = $3

        comment =~ /（(\d+)％）/
        status_effect_p = $1

        power = power == '-' ? '-' : power.to_i
        accuracy = accuracy == '-' ? '-' : accuracy.to_i

        @skill_info[name] = {
          'power'    => power,
          'accuracy' => accuracy,
          'max_pp'   => pp.to_i,
          'type'     => type,
          'category' => category == 'ぶつり' ? 'physical' : 'special',
          'direct?'  => direct == '○' ? true :false,
          'priority' => priority.to_i,
          'effect_code' => effect_code,
          'state_effect_p' => state_effect_p.nil? ? 100 : state_effect_p.to_i,
          'status_effect_p' => state_effect_p.nil? ? 100 : status_effect_p.to_i,
        }
      end
    end
  end

  def load_pokemon_status
    File.open('data/pokemon_shuzoku.csv', 'r:Shift_JIS:UTF-8') do |file|
      header = file.gets

      file.each_line do |line|
        number, name, hp, attack, defence, sp_atk, sp_def, speed, type = line.chomp.split(',')

        @pokemon_info[name] = {
          'number'  => number.to_i,
          'type'    => type.split('/'),
          's_hp'      => hp.to_i,
          's_attack'  => attack.to_i,
          's_defence' => defence.to_i,
          's_sp_atk'  => sp_atk.to_i,
          's_sp_def'  => sp_def.to_i,
          's_speed'   => speed.to_i
        }
      end
    end
  end

  def load_pokemon_skill
    File.open('data/pokemon_waza.dat', 'r:UTF-8') do |file|
      file.each_line do |line|
        name, *skill_list = line.chomp.split("\t")

        @pokemon_info[name]['available_skill'] = Hash.new

        skill_list.each do |data|
          level, skill = data.split(':')
          @pokemon_info[name]['available_skill'][skill] = level.to_i
        end

      end
    end
  end

  def pokemon (name, level = 5, 
               k = [31, 31, 31, 31, 31, 31],
               d = [85, 85, 85, 85, 85, 85],
               skill_list = nil)

    k_value = {
               'hp'      => k[0],
               'attack'  => k[1],
               'defence' => k[2],
               'sp_atk'  => k[3],
               'sp_def'  => k[4],
               'speed'   => k[5],
    }
    d_value = { 
               'hp'      => d[0],
               'attack'  => d[1],
               'defence' => d[2],
               'sp_atk'  => d[3],
               'sp_def'  => d[4],
               'speed'   => d[5],
    }

    skill = Array.new
    if skill_list.nil?
      @pokemon_info[name]['available_skill'].each_pair do |w, l|
        if level >= l && l != 0
          skill.push({
                       'name'   => w,
                       'pp'     => @skill_info[w]['max_pp'],
                       'max_pp' => @skill_info[w]['max_pp'],
                       'type'   => @skill_info[w]['type'],
                     })
        end
      end
    else
      skill_list.each do |skill_name|
        if !@pokemon_info[name]['available_skill'].has_key?(skill_name) || @pokemon_info[name]['available_skill'][skill_name] > level
          puts skill_name + " is needed Lv" + level.to_s
        end
        skill.push({
                     'name'   => skill_name,
                     'pp'     => @skill_info[skill_name]['max_pp'],
                     'max_pp' => @skill_info[skill_name]['max_pp'],
                     'type'   => @skill_info[skill_name]['type']})
      end
    end

    hp = (@pokemon_info[name]['s_hp'] * 2 + k_value['hp'] + d_value['hp']/4) * level / 100 + 10 + level

    pokemon = {
      'name'   => name,
      'level'  => level,
      'type'   => @pokemon_info[name]['type'],
      'hp'     => hp,
      'max_hp' => hp, 
      'skill'  => skill,
    }

    for key in ['attack', 'defence', 'sp_atk', 'sp_def', 'speed']
      pokemon[key] = ( (@pokemon_info[name]['s_'+key] * 2 + k_value[key] + d_value[key]/4) * level / 100 + 5 ) * 1
      pokemon['r_'+key] = 0
    end

    pokemon['r_accuracy'] = pokemon['r_evasion'] = pokemon['r_critical'] = 0

    pokemon['state'] = Hash.new
    pokemon['special_state'] = Hash.new

    return pokemon
  end

  def make_decision (pokemon, enemy)
    decision = nil
    best_action_score = -1
    pokemon['skill'].each_with_index do |skill, i|
      score = $zukan.estimate_action_score(pokemon, enemy, skill['name'])
      if score >= best_action_score
        best_action_score = score
        decision = i
      end
    end

    return decision
  end

  def calc_speed (pokemon)
    speed = (pokemon['speed'] * @rank_effect[pokemon['r_speed']]).to_i

    if pokemon['state'].key?('PAR')
      speed = (speed*0.25).to_i
    end

    return speed
  end

  def sort_by_speed (pokemon, decision, enemy, enemy_decision)
    priority = @skill_info[pokemon['skill'][decision]['name']]['priority']
    enemy_priority = @skill_info[enemy['skill'][enemy_decision]['name']]['priority']

    if priority > enemy_priority
      return pokemon, decision, enemy, enemy_decision
    elsif priority < enemy_priority
      return enemy, enemy_decision, pokemon, decision
    end

    speed = calc_speed(pokemon)
    enemy_speed = calc_speed(enemy)

    if speed > enemy_speed
      return pokemon, decision, enemy, enemy_decision
    elsif speed < enemy_speed
      return enemy, enemy_decision, pokemon, decision
    end

    if rand(100) > 50
      return pokemon, decision, enemy, enemy_decision
    else
      return enemy, enemy_decision, pokemon, decision
    end
  end

  def calc_base_damage (attacker, target, skill)
    if @skill_info[skill]['category'] == 'physical'
      attacker_status = (attacker['attack'] * @rank_effect[attacker['r_attack']]).to_i
      target_status = (target['defence'] * @rank_effect[target['r_defence']]).to_i
    else
      attacker_status = (attacker['sp_atk'] * @rank_effect[attacker['r_sp_atk']]).to_i
      target_status = (target['sp_def'] * @rank_effect[target['r_sp_def']]).to_i
    end
    damage = (attacker['level']*2/5 +2) * @skill_info[skill]['power'] * attacker_status / target_status / 50 + 2
    damage.to_i
  end

  def calc_self_type_effect (damage, attacker, skill)
    if attacker['type'].select{|type| type == @skill_info[skill]['type']}.size > 0
      effect = 1.5
    else
      effect = 1
    end

    return (damage * effect).to_i
  end

  def calc_target_type_effect (damage, skill, target)
    effect = 1.0

    target['type'].each do |target_type|
      effect *= @type_effect[@skill_info[skill]['type']][target_type]
    end

    case effect
      when 2.0, 4.0
      message = 'こうかは ばつぐんだ！'
      when 0.25, 0.5
      message = 'こうかは いまひとつの ようだ'
      when 0
      message = sprintf '%sには こうかが ない みたいだ・・・', target['name']
      when 1.0
      message = nil
    end
    
    damage = (damage * effect).to_i

    return damage, message
  end

  def calc_critical_effect (damage, message, attacker)
    if damage == 0
      return damage, message
    end

    critical = @rank_effect_critical[attacker['r_critical']]
    if rand(100) > 0
      return damage, message
    end

    message = message.nil? ? 'きゅうしょに あたった！' : 'きゅうしょに あたった！' + "\n" + message

    return damage*2, message
  end

  def calc_random_effect (damage)
    return (damage * ( 100 - rand(16) ) / 100.0).to_i
  end

  def damage_proc(attacker, target, skill)

    damage = calc_base_damage(attacker, target, skill)
    damage = calc_self_type_effect(damage, attacker, skill)
    damage, message = calc_target_type_effect(damage, skill, target)
    damage, message = calc_critical_effect(damage, message, attacker)
    damage = calc_random_effect(damage)

    target['hp'] -= damage
    target['prev_damage'] = damage
    if !message.nil?
      puts message
    end
    printf "[%s ダメージ%d]\n", target['name'], damage

    return damage
  end

  def miss? (attacker, target, skill)
    rank_diff = attacker['r_accuracy'] - target['r_evasion']
    rank_diff = rank_diff > 6 ? 6 : rank_diff
    rank_diff = rank_diff < -6 ? -6 : rank_diff

    if @skill_info[skill]['accuracy'] != '-'
      accuracy = (@skill_info[skill]['accuracy'] * @rank_effect_accuracy[rank_diff]).to_i
      if rand(100) > accuracy
        printf "しかし %sの こうげきは はずれた\n", attacker['name']
        return true
      end
    end

    return false
  end

  def status_proc(target, status, rank, p)
    if !p.nil?
      if rand(100) > p
        return
      end
    end

    target['r_'+status] += rank

    if target['r_'+status] > 6
      target['r_'+status] = 6
    end

    if target['r_'+status] < -6
      target['r_'+status] = -6
    end

    case rank
    when 3
      message = 'ぐぐーんと あがった'
    when 2
      message = 'ぐーんと あがった'
    when 1
      message = 'あがった'
    when -1
      message = 'さがった'
    when -2
      message = 'がくっと さがった'
    when -4
      message = 'がくーんと さがった'
    end

    printf "%sの %sが %s\n", target['name'], @status_str[status], message
  end

  def recovery_proc(target, value, rate)
    recovery = (value * rate).to_i
    if target['hp'] + recovery > target['max_hp']
      recovery = target['max_hp'] - target['hp']
    end

    target['hp'] += recovery
    printf "[%s 回復%d]", target['name'], recovery
  end

  def recoil_proc (target, value, rate)
    recoil = (value * rate).to_i
    
    target['hp'] -= recoil
    printf "[%s 反動ダメージ%d]", target['name'], recoil
  end

  def state_proc (target, state, p)

    if target['state'].size != 0
      puts 'しかし うまく きまらなかった'
      return
    end

    if !p.nil?
      if rand(100) > p
        puts 'しかし うまく きまらなかった'
        return
      end
    end

    if state == 'SLP'
      target['state'][state] = rand(3) + 2 # 2...4
    else
      target['state'][state] = 1
    end

    printf "%s%s\n", target['name'], @state_message[state+'_START']
  end

  def special_state_proc (target, special_state, p)
    if target['special_state'].key?(special_state)
      puts 'しかし うまく きまらなかった'
      return
    end

    if !p.nil?
      if rand(100) > p
        puts 'しかし うまく きまらなかった'
        return
      end
    end

    target['special_state'][special_state] = 1
  end

  def pre_proc (target)
    if target['state'].key?('SLP')
      target['state']['SLP'] -= 1
      if target['state']['SLP'] == 0
        printf "%s%s\n", target['name'], @state_message['SLP_END']
        target['state'].delete('SLP')
        return true
      else
        printf "%s%s\n", target['name'], @state_message['SLP_CONTINUE']
        return false
      end
    end

    if target['state'].key?('FRZ')
      if rand(100) > 25
        printf "%s%s\n", target['name'], @state_message['FRZ_END']
        target['state'].delete('FRZ')
        return true
      else
        printf "%s%s\n", target['name'], @state_message['FRZ_CONTINUE']
        return false
      end
    end

    if target['state'].key?('PAR')
      if rand(100) > 25
        printf "%s%s\n", target['name'], @state_message['PAR_CONTINUE']
        return false
      end
    end

    return true
  end

  def post_proc (pokemon, enemy)
    if pokemon['state'].key?('PSN')
      damage = (pokemon['max_hp']/8).to_i
      printf "%s%s\n", pokemon['name'], @state_message['PSN_CONTINUE']
      printf "[%s ダメージ%d]\n", pokemon['name'], damage
      pokemon['hp'] -= damage
    end

    if pokemon['state'].key?('PSN2')
      damage = (pokemon['state']['PSN2'] * pokemon['max_hp'] / 16).to_i
      printf "%s%s\n", pokemon['name'], @state_message['PSN_CONTINUE']
      printf "[%s ダメージ%d]\n", pokemon['name'], damage
      pokemon['hp'] -= damage

      pokemon['state']['PSN2'] += 1
      if pokemon['state']['PSN2'] == 16
        pokemon['state']['PSN2'] = 15
      end
    end

    if pokemon['state'].key?('BRN')
      damage = (pokemon['max_hp']/8).to_i
      printf "%s%s\n", pokemon['name'], @state_message['BRN_CONTINUE']
      printf "[%s ダメージ%d]\n", pokemon['name'], damage
      pokemon['hp'] -= damage
    end

    if pokemon['special_state'].key?('SEED')
      damage = (pokemon['max_hp']/8).to_i
      recover = damage
      if enemy['hp'] + recover > enemy['max_hp']
        recover = enemy['max_hp'] - enemy['hp']
      end

      printf "[%s やどりぎのタネによるダメージ%d]\n", pokemon['name'], damage
      printf "[%s やどりぎのタネによる回復%d]\n", enemy['name'], recover
      pokemon['hp'] -= damage
      enemy['hp'] += recover
      
    end
  end

  def skill_proc (attacker, target, skill)
    if miss?(attacker, target, skill)
      return
    end

    if @skill_info[skill]['power'] != '-'
      case @skill_info[skill]['effect_code']
      when '0090' # ミラーコート
        damage = 2 * attacker['prev_damage']
        target['hp'] -= damage
        printf "[%s ダメージ%d]\n", target['name'], damage
      else
        damage = damage_proc(attacker, target, skill)  
      end
    end

    sleep(1)

    if target['hp'] <= 0
      return
    end

    status_effect_p = @skill_info[skill]['status_effect_p']
    state_effect_p = @skill_info[skill]['state_effect_p']

    case @skill_info[skill]['effect_code']
      when '0000'

      when '000A', '008B'
      status_proc(attacker, 'attack',   1, status_effect_p)
      when '000B', '008A', '009C'
      status_proc(attacker, 'defence',  1, status_effect_p)
      when '00AE'
      status_proc(attacker, 'sp_def',   1, status_effect_p)
      when '0114', '0127'
      status_proc(attacker, 'speed',    1, status_effect_p)
      when '0010'
      status_proc(attacker, 'evasion',  1, status_effect_p)

      when '0032', '0076'
      status_proc(attacker, 'attack',   2, status_effect_p)
      when '0033'
      status_proc(attacker, 'defence',  2, status_effect_p)
      when '0034', '011C'
      status_proc(attacker, 'speed',    2, status_effect_p)
      when '0035'
      status_proc(attacker, 'sp_atk',   2, status_effect_p)
      when '0036'
      status_proc(attacker, 'sp_def',   2, status_effect_p)
      when '006C'
      status_proc(attacker, 'evasion',  2, status_effect_p)

      when '0148'
      status_proc(attacker, 'defence',  3, status_effect_p)
      when '0141'
      status_proc(attacker, 'sp_atk',   3, status_effect_p)

      when '00CE'
      status_proc(attacker, 'defence',  1, status_effect_p)
      status_proc(attacker, 'sp_def',   1, status_effect_p)
      when '00D0'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'defence',  1, status_effect_p)
      when '013C', '0147'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'sp_atk',   1, status_effect_p)
      when '00D3'
      status_proc(attacker, 'sp_atk',   1, status_effect_p)
      status_proc(attacker, 'sp_def',   1, status_effect_p)
      when '00D4'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'speed',    1, status_effect_p)
      when '0115'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'accuracy', 1, status_effect_p)
      when '0138'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'speed',    2, status_effect_p)
      when '0122'
      status_proc(attacker, 'sp_atk',   1, status_effect_p)
      status_proc(attacker, 'sp_def',   1, status_effect_p)
      status_proc(attacker, 'speed',    1, status_effect_p)
      when '0142'
      status_proc(attacker, 'attack',   1, status_effect_p)
      status_proc(attacker, 'defence',  1, status_effect_p)
      status_proc(attacker, 'accuracy', 1, status_effect_p)

      when '0012', '0044'
      status_proc(target, 'attack',   -1, status_effect_p)
      when '0013', '0045'
      status_proc(target, 'defence',  -1, status_effect_p)
      when '0014', '0046', '00DA', '014A'
      status_proc(target, 'speed',    -1, status_effect_p)
      when '0047'
      status_proc(target, 'sp_atk',   -1, status_effect_p)
      when '0048'
      status_proc(target, 'sp_def',   -1, status_effect_p)
      when '0017'
      status_proc(target, 'accuracy', -1, status_effect_p)
      when '0018', '0049'
      status_proc(target, 'evasion',  -1, status_effect_p)

      when '003A'
      status_proc(target, 'attack',  -2, status_effect_p)
      when '003B'
      status_proc(target, 'defence', -2, status_effect_p)
      when '003C'
      status_proc(target, 'speed',   -2, status_effect_p)
      when '003E', '010F', '0128'
      status_proc(target, 'sp_def',  -2, status_effect_p)

      when '00CD'
      status_proc(target, 'attack',  -1, status_effect_p)
      status_proc(target, 'defence', -1, status_effect_p)

      when '00CC'
      status_proc(attacker, 'sp_atk',  -2, status_effect_p)
    when '00B6'
      status_proc(attacker, 'attack',  -1, status_effect_p)
      status_proc(attacker, 'defence', -1, status_effect_p)
      when '00E5'
      status_proc(attacker, 'defence', -1, status_effect_p)
      status_proc(attacker, 'sp_def',  -1, status_effect_p)
      when '014E'
      status_proc(attacker, 'defence', -1, status_effect_p)
      status_proc(attacker, 'sp_def',  -1, status_effect_p)
      status_proc(attacker, 'speed',   -1, status_effect_p)

      when '009C'
      status_proc(target, 'attack', 1, status_effect_p)
      when '008C'
      if rand(100) > status_effect_p
        status_proc(attacker, 'attack',  1, nil)
        status_proc(attacker, 'defence', 1, nil)
        status_proc(attacker, 'sp_atk',  1, nil)
        status_proc(attacker, 'sp_def',  1, nil)
        status_proc(attacker, 'speed',   1, nil)
      end

      when '0003', '0008'
      recovery_proc(attacker, damage, 0.5)
      when '0020', '0084', '00D6'
      recovery_proc(attacker, attacker['max_hp'], 0.5)
      when '0135'
      recovery_proc(target, target['max_hp'], 0.5)

      when '0030'
      recoil_proc(attacker, damage, 0.25)
      when '00C6', '00FD', '0106', '010D'
      recoil_proc(attacker, damage, 1.0/3)

      when '0001'
      state_proc(target, 'SLP', state_effect_p)
      when '0002', '0042', '00D1' # その他 どくのこな/どくガス ポイズンテール/クロスポイズン
      state_proc(target, 'PSN', state_effect_p)
      when '0021', '00CA' # どくどく どくどくのキバ
      state_proc(target, 'PSN2', state_effect_p)
      when '0004', '007D', '00C8', '00FD' # その他 かえんぐるま/せいなるほのお ブレイズキック フレアドライブ
      state_proc(target, 'BRN', state_effect_p)
      when '0005', '0104' # その他 ふぶき
      state_proc(target, 'FRZ', state_effect_p)
      when '0006', '0043', '0098', '0106' # その他 しびれごな/へびにらみ/でんじは かみなり ボルテッカー
      state_proc(target, 'PAR', state_effect_p)

      when '0054' # やどりぎのタネ
      special_state_proc(target, 'SEED', state_effect_p)


    end

    puts
  end

  def estimate_action_score(attacker, target, skill)

    if @skill_info[skill]['power'] != '-'
      damage = calc_base_damage(attacker, target, skill)
      damage = calc_self_type_effect(damage, attacker, skill)
      damage, message = calc_target_type_effect(damage, skill, target)
      return damage
    else
      return 0
    end
  end

end
