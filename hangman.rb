require "yaml"
class Game
    attr_accessor :word
    def initialize
        @word = File.readlines("dictionary.txt").sample(1)[0].to_s.strip.downcase
    end
    
    def save_game(game)
        game = YAML::dump(game)
        Dir.mkdir("saved_games") unless Dir.exists?("saved_games")
        puts "What would you like to call your game?"
        filename = "saved_games/" + gets.chomp + ".txt"
        File.open(filename, "w") do |file|
            file.puts game
        end
    end

    def guess(letter)
        while @already_guessed.include?(letter) do
            puts "You already guessed that letter!"
            letter = gets.chomp.downcase
        end
        index = 0
        @word.length.times do
            if letter == @word[index]
                @word_with_guesses[index] = letter
            end
            index += 1
        end
        unless @word.include?(letter)
            @already_guessed.push(letter)
            @guesses -= 1
        end
        puts "Letters Guessed: " + @already_guessed.join("")
        puts "You have #{@guesses} incorrect guesses left."
        if @guesses > 0
            puts @word_with_guesses.join("")
        elsif @guesses == 0
            puts @word
        end
    end

    def play
          until @guesses == 0 do  
            puts "Enter a letter to guess"
            letter = gets.chomp.downcase
            if letter == "save"
                save_game(self)
                break
            end
            while letter !~ /\A[a-zA-Z]\z/ do
                puts "Enter a single letter to guess"
                letter = gets.chomp.downcase
            end
            guess(letter)
            unless @word_with_guesses.include?("_")
                puts "You Win!"
                break
            end
            if @guesses == 0
                puts "You lose"
            end
        end
    end

    def play_new_game
        @guesses = 6
        @already_guessed = []
        accumulator = 0
        @word_with_guesses = []
        @word.length.times do
            @word_with_guesses.push("_")
        end
        puts "Type 'save' at any time to save your game."
        puts "You have 6 incorrect guesses left."
        puts @word_with_guesses.join("")
        play
    end

    def play_saved_game
        puts "Type 'save' at any time to save your game."
        puts "Letters Guessed: " + @already_guessed.join("")
        puts "You have #{@guesses} incorrect guesses left."
        puts @word_with_guesses.join("")
        play
    end

end

def load_game(game)
    File.open(game, "r") do |file|
        YAML::load(file)
    end
end

if !Dir.exists?("saved_games")
    puts "Saved Games: none \nType new to start a new game."
elsif Dir.empty?("saved_games")
    puts "Saved Games: none \nType new to start a new game."
else
    puts "Saved Games: "
    games = Dir["saved_games/*"]
    games.each do |file|
        file = file.sub(/\A[^\/]*\//, '')
        file = file.sub(/.txt/, '')
        puts file
    end
    puts "Type the name of your saved game to load, or new to start a new game."
end


game_name = gets.chomp.downcase
if game_name == "new"
    new_game = Game.new
    p new_game.word
    new_game.play_new_game
else
    saved_game = load_game("saved_games/" + game_name + ".txt")
    saved_game.play_saved_game
end