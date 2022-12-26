require './lexer'
require './parser'

def main
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
          puts "input file: #{input_file}"
          mylex = Lexer.new(f)
          p = Parser.new(mylex, "#{input_file.slice(/\d.+/)}.out")
          p.parse
        end
      end

    return
    end
  end
  mylex = Lexer.new($stdin)
  p = Parser.new(mylex)
  p.parse # lexer.lex()の戻り値(true/false)が返ってきてる
end

main
