# :coding : UTF-8

File.open('data/type.csv', 'r:Shift_JIS:UTf-8') do |file|
  type = file.gets.chomp.split(',')
  type.shift # dust

  file.each_line do |line|
    waza_type, *weight_list = line.chomp.split(',')

    weight_list.each_with_index do |weight, i|
      if weight == ''
        weight = "1"
      end

      puts waza_type + "\t" + type[i] + "\t" + weight
    end
  end
end

