require './lexer'
require './parser'

def testForOutput
  puts "\n"
  puts '------動作確認結果------'
  outputs = Dir.glob('./output/*.out').sort
  count_file = 1
  count_ok = 0
  count_ng = 0
  outputs.each do |output_file|
    filename = File.basename(output_file)
    is_next = false

    # 出力したファイルが正常なコードに対する出力であるなら
    if filename.slice(4, 4) == 'pass'
      File.open(output_file).each do |line|
        if line.include?('error!')
          puts "#{format('%03d', count_file)} NG: #{filename}"
          count_ng += 1
          count_file += 1
          is_next = true
          break
        end
      end
      next if is_next
      puts "#{format('%03d', count_file)} OK: #{filename}"
      count_ok += 1
      count_file += 1
      # 出力したファイルがエラーとなるコードに対する出力であるなら
    else
      err_kind = 
        case filename.slice(8, 3)
        when 'syn'
          'Syntax error!'
        when 'sem'
          'Semantic error!'
        when 'run'
          'Runtime error!'
        else
          puts "#{format('%03d', count_file)} Wrong file name: #{filename}"
          count_file += 1
          next
        end
      File.open(output_file).each do |line|
        if line.include?(err_kind)
          puts "#{format('%03d', count_file)} OK: #{filename}"
          count_ok += 1
          count_file += 1
          is_next = true
          break
        end
      end
      next if is_next
      puts "#{format('%03d', count_file)} NG: #{filename}"
      count_ng += 1
      count_file += 1
    end
  end
  puts "#{count_ok + count_ng}/#{outputs.size}ファイルの動作確認を完了"
  puts "動作確認結果OK: #{count_ok}ファイル"
  puts "動作確認結果NG: #{count_ng}ファイル"
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

        count = 1
        inputs.each do |input_file|
          File.open(input_file, 'r') do |f|
            puts "#{format('%03d', count)} input file: #{File.basename(input_file)}"
            mylex = Lexer.new(f)
            p = Parser.new(mylex, "#{File.basename(input_file)}.out")
            count += 1
            begin
              p.parse
            rescue SystemExit
              puts ''
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
