require 'json'
FILE_READ_ERROR = -1
SAVE_TOKEN = 1010
LOAD_TOKEN = 1011

class Game
  def initialize
    @hangman = Hangman.new
    greet
  end

  def play
    while @hangman.lives.positive?
      input = false
      until input
        input = @hangman.read_char
        puts 'Invalid character' unless input
      end

      return save_game if input == SAVE_TOKEN
      return load_game if input == LOAD_TOKEN

      status = @hangman.compare_guess
      return puts 'You win!' if @hangman.won

      @hangman.display(status)
    end
    puts "You lose! The word was #{@hangman.word_array.join}"
  end

  private

  def greet
    puts 'Lets play hangman!'
    puts 'You can also save your game with \'save\' or load the most recent save with \'load\''
    string = @hangman.word_array.map { '-' }.join
    puts string
  end

  def save_game
    save_data = @hangman.to_json
    File.open('save_data.json', 'w') { |file| file.write(save_data) }
  end

  def load_game
    if File.exist?('save_data.json')
      saved_data = File.read('save_data.json')
      @hangman = Hangman.from_json(saved_data)
      puts 'Game loaded successfully!'
      @hangman.display(@hangman.compare_guess)
    else
      puts 'No save data found. Starting a new game.'
    end
    play
  end
end

class Hangman
  attr_reader :lives, :word_array, :won

  @@filename = 'google-10000-english-no-swears.txt'

  def initialize(word_array: nil, guess: '', lives: 7, won: false)
    if word_array.nil?
      @word_array = random_word(read_word_file(@@filename)).chars
    else
      @word_array = word_array
    end
    @guess = guess
    @lives = lives
    @won = won
  end

  def read_char
    char = gets.chomp.downcase
    return SAVE_TOKEN if char == 'save'
    return LOAD_TOKEN if char == 'load'
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

  def to_json(*options)
    {
      word_array: @word_array,
      guess: @guess,
      lives: @lives,
      won: @won
    }.to_json(*options)
  end

  def self.from_json(json)
    data = JSON.parse(json)
    new(
      word_array: data['word_array'],
      guess: data['guess'],
      lives: data['lives'],
      won: data['won']
    )
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