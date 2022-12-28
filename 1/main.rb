require './lexer'
require './parser'

def testForOutput
  puts "\n\n"
  puts '------動作確認結果------'
  outputs = Dir.glob('./output/*.out').sort
  count = 0
  outputs.each do |output_file|
    filename = output_file.slice(/\d.+/)
    is_next = false

    # 出力したファイルが正常なコードに対する出力であるなら
    if filename.slice(3, 4) == 'pass'
      File.open(output_file).each do |line|
        if line.include?('error!')
          puts "NG: #{filename}"
          count += 1
          is_next = true
          break
        end
      end
      next if is_next
      puts "OK: #{filename}"
      count += 1
    # 出力したファイルがエラーとなるコードに対する出力であるなら
    else
      err_kind = 
        case filename.slice(7, 3)
        when 'syn'
          'Syntax error!'
        when 'sem'
          'Semantic error!'
        when 'run'
          'Runtime error!'
        else
          puts "Wrong file name: #{filename}"
          next
        end
      File.open(output_file).each do |line|
        if line.include?(err_kind)
          puts "OK: #{filename}"
          count += 1
          is_next = true
          break
        end
      end
      next if is_next
      puts "NG: #{filename}"
      count += 1
    end
  end
  puts "#{count}/#{outputs.size}ファイルの動作確認を完了"
end

def main
  if !(ARGV.empty?) && ARGV[0] == '--use-input-file'
    # inputフォルダがあるなら
    if Dir.exist?('./input')
      inputs = Dir.glob('./input/*.pas').sort
      # inputフォルダ内にpasファイルが1つ以上あるなら
      if !(inputs.empty?)
        if !(Dir.exist?('./output'))
          Dir.mkdir('./output')
        end

        inputs.each do |input_file|
          File.open(input_file, 'r') do |f|
            puts ''
            puts "input file: #{input_file}"
            mylex = Lexer.new(f)
            p = Parser.new(mylex, "#{input_file.slice(/\d.+/)}.out")
            begin
              p.parse
            rescue SystemExit
              next
            end
          end
        end

        testForOutput
        return
      else
        puts 'It\'s unable to use input files because of no input file.'
      end
    else
      puts 'It\'s unable to use input files because of no input folder.'
    end
  end
  puts "Type your acl code!\n\n"
  mylex = Lexer.new($stdin)
  p = Parser.new(mylex)
  p.parse # lexer.lex()の戻り値(true/false)が返ってきてる
end

main
