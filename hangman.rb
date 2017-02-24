require 'json'


class Hangman
  attr_accessor :player, :secret_word, :guess_array, :word_to_guess
  @@guesses = 9
  @@misses_array = []



  def initialize
    @secret_word = select_secret_word
    @word_to_guess = @secret_word.split("")
    @guess_array = Array.new(@word_to_guess.length , " _ ")
    
    puts "WELCOME TO HANGMAN!!! \n\n\n"

    loop do
      puts %q{Please select an option:
      1. Start a new game
      2. Load an existing game
      3. Quit}
      case gets.chomp
        when '1'
        new_game
        when '2'
        load_game
        when '3'
        quit
      end
    end
  end

  def new_game
    puts "Please write your name"
    player_name = gets.chomp  
    @player = player_name
    start
  end

  def read_words_file
    lines = File.readlines "5desk.txt"
    lines.each {|line| line.delete!("\n")}
  end

  def select_usable_words
    lines = read_words_file
    usable_words = lines.select {|line| line.length > 5 && line.length < 12 }
  end

  def select_secret_word
    usable_words = select_usable_words
    secret_word = usable_words.sample
    return secret_word
  end

  def start
    while !game_over?
      player_turn
      display_board
    end    
  end

  def game_choice
    if @@guesses == 9 
      typed_choice = 1
    else
      puts "\n\n If you want to continue playing please type number 1, if you want to save this game, type number 2:"
      typed_choice = gets.chomp.to_i

    end
  end

  def player_turn
    typed_choice = game_choice 
    if typed_choice == 1
      puts "Please #{@player} make your guess by choosing a letter:"
      chosen_letter = gets.chomp.downcase

      validate_guess(chosen_letter)    
    else
      save_game
    end
    @@guesses -= 1 
  end

  def validate_guess(letter)  
    @word_to_guess.each_with_index do |l, i|
      @guess_array[i] = l if l == letter
    end
    @@misses_array << letter
  end


  def game_over?

    if victory?
      puts "\n\n#{@player} WINS!!\n\n"
      return true      
    elsif no_guesses_left?
      puts "\n\nGAME OVER, NO GUESSES LEFT :( 
        \n the secret word was: #{@secret_word}\n\n"
      return true
    else
      return false
    end
  end

  def victory?
    if @guess_array == @word_to_guess
      return true
    else
      return false
    end
  end

  def no_guesses_left?
    if @@guesses == 0
      return true
    else
      return false
    end
  end


  def display_board

    print "\n\n"
    puts "_________________________________________________________________________________________________________________"
    puts "This is your guess: \n\n"
    print @guess_array
    print "\n\n"
    puts "\n This are the letters you have try this far:\n\n"
    print @@misses_array
    print "\n\n"
    puts "Turns left: #{@@guesses}\n\n"
    puts "__________________________________________________________________________________________________________________"

  end

  def save_game
      Dir.mkdir('games_saved') unless Dir.exist? 'games_saved'
      
      print "\n Please name the game you want to save: "
      game_name = gets.chomp
      Dir.chdir("games_saved")
      save_file = File.open(game_name,'w+')
      json_string = to_json
      save_file.write(json_string)
      save_file.close
      Dir.chdir("..")
      puts "SAVED GAME SUCCESSFULY!"
      exit
  end

  def to_json
    JSON.dump ({
      :name => @player,
      :guesses => @@guesses,
      :misses_array => @@misses_array,
      :secret_word => @secret_word,
      :word_to_guess => @word_to_guess,
      :guess_array => @guess_array
      })
  end

  def from_json(string)
    data = JSON.parse(string)
      @player = data['name']
      @@guesses = data['guesses']
      @@misses_array = data['misses_array']
      @secret_word = data['secret_word']
      @word_to_guess = data['word_to_guess']
      @guess_array = data['guess_array']
  end

  def load_game
    puts "\n These are the games saved\n"
    Dir.foreach('games_saved') {|file| puts "File: #{file}" }
    print "\n\n\n"
    puts "Please choose a file from the games saved to resume game:"
    file_chosen = gets.chomp.downcase
    puts "\n\n you have chosen this file: #{file_chosen}\n\n"

    Dir.chdir("games_saved")
    load_file = File.read(file_chosen)
    from_json(load_file)
    Dir.chdir("..")
    display_board
    puts "GAME LOADED SUCCESSFULY!"
    start
  end

  def quit
    puts "Bye!"
    exit
  end

end

my_game = Hangman.new




