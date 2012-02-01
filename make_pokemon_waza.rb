# :coding : UTF-8

waza_machine = Hash.new

File.open('data/machine.csv', 'r:Shift_JIS:UTF-8') do |file|
  file.each_line do |line|
    id, waza = line.chomp.split(',')

    waza_machine[id] = waza
  end
end

machine_waza = Hash.new

File.open('data/pokemon_waza_machine.csv', 'r:Shift_JIS:UTF-8') do |file|
  file.each_line do |line|
    number, name, *waza_list = line.chomp.split(',');

    machine_waza[name] = waza_list.map{|id| waza_machine[id]}
  end
end

tamago_waza = Hash.new

File.open('data/pokemon_waza_tamago.csv', 'r:Shift_JIS:UTF-8') do |file|
  file.each_line do |line|
    number, name, *waza_list = line.chomp.split(',');

    tamago_waza[name] = waza_list
  end
end

File.open('data/pokemon_waza_level.csv', 'r:Shift_JIS:UTF-8') do |file|
  file.each_line do |line|
    number, name, *waza_list = line.chomp.split(',');

    # print number + "\t"
    print name

    if machine_waza.has_key?(name)
      print "\t" + machine_waza[name].map{|x| "0:" + x}.join("\t")
    end
    
    if tamago_waza.has_key?(name)
      tamago_waza_list = tamago_waza[name].reject{|x| machine_waza.has_key?(x) }
      if tamago_waza_list.size != 0
        print "\t" + tamago_waza_list.map{|x| "0:" + x}.join("\t");
      end
    end

    not_uniq = Hash.new

    waza_list.each do |data|
      a = data.split(':')
      
      level = a[0]
      waza = a[1]

      if !machine_waza.has_key?(waza) && !tamago_waza.has_key?(waza) && !not_uniq[waza]
        print "\t" + level + ":" + waza
        not_uniq[waza] = 1
      end
    end

    puts
  end
end

