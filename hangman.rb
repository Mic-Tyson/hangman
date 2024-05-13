FILE_READ_ERROR = -1

class Game
  def initialize
    @hangman = Hangman.new
  end

  def play
    greet
    while @hangman.lives.positive?
      puts 'Invalid letter' until @hangman.read_char
      status = @hangman.compare_guess
      return puts 'You win!' if @hangman.won

      @hangman.display(status)
    end
    puts "You lose! The word was #{@hangman.word_array.join}"
  end

  private

  def greet
    puts 'Lets play hangman!'
  end
end

class Hangman
  attr_reader :lives, :word_array, :won

  @@filename = 'google-10000-english-no-swears.txt'

  def initialize
    @word_array = random_word(read_word_file(@@filename)).chars
    @guess = ''
    @lives = 7
    @won = false
  end

  def read_char
    char = gets.chomp.downcase
    return false unless valid_guess?(char)

    @guess += char
    true
  end

  def compare_guess
    @lives -= 1 unless @word_array.include?(@guess[-1])
    filtered_chars = @word_array.filter{ |char| !@guess.include?(char) }.join
    filtered_word = @word_array.join.tr(filtered_chars, '-')
    filtered_word == @word_array.join ? @won = true : filtered_word
  end

  def display(string)
    puts string
    puts "You have #{@lives} lives left" unless @won
  end

  private

  def valid_guess?(str)
    char?(str) && str.match?(/[a-zA-Z]/)
  end

  def char?(str)
    str.length == 1
  end

  def read_word_file(filename)
    return FILE_READ_ERROR unless File.exist? filename

    File.readlines(filename).filter { |word| word.length.between?(5, 12) }
  end

  def random_word(dictionary)
    dictionary.sample.chomp unless dictionary == FILE_READ_ERROR
  end
end

test = Game.new
test.play