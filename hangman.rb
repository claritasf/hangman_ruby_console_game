require 'json'


class Hangman
  attr_accessor :player, :secret_word, :guess_array, :word_to_guess
  @@guesses = 9
  @@misses_array = []



  def initialize
    @secret_word = select_secret_word
    @word_to_guess = @secret_word.split("")
    @guess_array = Array.new(@word_to_guess.length , " _ ")
    
    puts "WELCOME TO HANGMAN!!! \n\n\n You'll have to guess the word before you run out of plays\n\n"
    puts "You want to start a new game or continue playing a saved game?, type \"new\"  or \"load\""
    @player_choice = gets.chomp.downcase
    if @player_choice == "new"
      puts "Please write your name"
      player_name = gets.chomp  
      @player = player_name
      start
    else
      load_game
    end
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
    if @@guesses == 9 || @player_choice == "load"
      typed_choice = 1
    else
      puts "\n\n If you want to continue playing please type number 1, if you want to save this game, type number 2:"
      typed_choice = gets.chomp.to_i
  #      until game_choice == 1 || game_choice == 2
  #        puts "\n\n Invalid answer! \n\n Please you have to type: \"1 to continue playing \" or \"2 to save this game\""
  #        game_choice = gets.chomp.to_i
  #      end
    end
  end

  def player_turn
    typed_choice = game_choice 
    if typed_choice == 1
      puts "Please #{@player} make your guess by choosing a letter:"
      chosen_letter = gets.chomp.downcase
      #until valid_input?(guessed_array)
      #  puts "\nAt least one of your inputs is not valid, please type them again, separated by a single space, remeber you must type 4 valid colors between: \"red, yellow, green, blue, orange, purple\" \n "
      #  guessed_array = gets.chomp.downcase.split
      #end
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
      puts "#{@player} WINS!!"
      return true      
    elsif no_guesses_left?
      puts "GAME OVER, NO GUESSES LEFT :( 
        \n the secret word was: #{@secret_word}"
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

end



my_game = Hangman.new




