require 'open-uri'
require 'json'


class GamesController < ApplicationController

  @@grid = "";

  def new
    @letters = generate_grid(10)
    @@grid = @letters
  end

  def score
    @score = run_game(params[:answer], @@grid)[:message]
  end
end

def generate_grid(grid_size)
  alphabet = ("a".."z").to_a
  grid = []
  grid_size.times { grid << alphabet.sample }
  return grid
end

def run_game(attempt, grid)
  attempt = attempt.downcase
  url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
  response = open(url).read
  result = JSON.parse(response)
  create_message(result, attempt, grid)
end

def letters_exist?(attempt, grid)
  my_hash = Hash.new(0)
  exist = true
  grid.each { |item| my_hash[item.downcase] += 1 }
  attempt.split("").each do |item|
    exist = false if my_hash[item] <= 0
    break unless exist
    my_hash[item] -= 1
  end
  exist
end

def create_message(result, attempt, grid)
  score = 0
  if !letters_exist?(attempt, grid)
    message = "not in the grid"
  elsif result["found"] == true
    score = attempt.length
    message = "Well done"
  else
    message = "not an english word"
  end
  { score: score, message: message }
end
