#! /usr/bin/ruby

require './pioneer.rb'
require './card.rb'

def score_cards(pioneer)
   cards = pioneer.cards
   score = 0
   
   # first off, if they don't have 6 cards, they get 0 points
   return score unless cards.size() == 6
   
   # next we can get all bonus cards points right away and take those out of the cards, since those are the same value for all
   # score += points_for_bonus_cards(cards)
   # cards = remove_bonus_cards(cards)
   
   # the rest of the score depends on what type of Pioneer they are
   score += case pioneer.profession
      when "Cowboy"        then score_cowboy_cards(cards)
      when "Prospector"    then score_prospector_cards(cards)
      when "Homesteader"   then score_homesteader_cards(cards)
      when "Trapper"       then score_trapper_cards(cards)
   end
   score
end

def drop_all_tools_except(cards, tool_type)
   cards.reject { |card| Card.TOOLS.include?(card.type) && card.type != tool_type }
end

def get_highest_value_tool_card(cards)
   highest_tool = nil
   cards.select { |card| Card.TOOLS.include? card.type }.each do |tool_card|
      if highest_tool.nil?
         highest_tool = tool_card 
      else
         highest_tool = tool_card if tool_card.value > highest_tool.value
      end
   end
   highest_tool
end

def filter_tool_cards(cards, tool_type)
   # get rid of all non-specified tools
   cards = drop_all_tools_except(cards, tool_type)
   
   # get the highest value of that type
   highest_tool = get_highest_value_tool_card(cards)
   
   # drop the rest of the lassos, then add in the highest one (unless it's nil of course)
   cards = drop_all_of_type(cards, tool_type)
   cards << highest_tool unless highest_tool.nil?
   
   cards
end

def drop_all_resources_except(cards, resource_type)
   cards.reject { |card| Card.RESOURCES.include?(card.type) && card.type != resource_type }
end

def drop_all_lands(cards)
   cards.reject { |card| Card.LANDS().include? card.type }
end

def drop_all_of_type(cards, type)
   cards.reject { |card| card.type == type }
end

def have_at_least_one(cards, type)
   if cards.detect { |card| card.type == type }.nil?
      false
   else
      true
   end
end

def score_horses_and_burros(cards, score)
   # half value for horses in mountains, double for burros
   if have_at_least_one(cards, "Mountain")
      cards.select { |card| card.type == "Horse" }.each { |card| score += (card.value * 0.5).round }
      cards.select { |card| card.type == "Burro" }.each { |card| score += (card.value * 2) }
      # now get rid of the horses and burros
      cards = drop_all_of_type(cards, "Horse")
      cards = drop_all_of_type(cards, "Burro")
   end
   return cards, score
end

def score_cowboy_cards(cards)
   score = 0
   
   cards = filter_tool_cards(cards, "Lasso")
   
   # now get rid of all non-cattle resources
   cards = drop_all_resources_except(cards, "Cattle")
   
   # if they have no lassos then they get no points for cattle
   if !have_at_least_one(cards, "Lasso")
      cards = drop_all_of_type(cards, "Cattle")
   end
   
   # if cowboys have no horse, no points for cattle (poor guys)
   if !have_at_least_one(cards, "Horse")
      cards = drop_all_of_type(cards, "Cattle")
   end
   
   # cattle value is full for plains, 1/2 for mountains, 0 for forest
   if have_at_least_one(cards, "Plains")
      # cattle are full value
      cards.select { |card| card.type == "Cattle" }.each { |card| score += card.value }
   elsif have_at_least_one(cards, "Mountain")
      # cattle are half value (rounding up to be nice)
      cards.select { |card| card.type == "Cattle" }.each { |card| score += (card.value * 0.5).round }
   else
      # cattle are worth zilch, boo
   end
   
   # drop all cattle now
   cards = drop_all_of_type(cards, "Cattle")
   
   cards, score = score_horses_and_burros(cards, score)
   
   # all remaining cards are full value
   cards.each { |card| score += card.value }
   
   score
end

def score_prospector_cards(cards)
   score = 0
   
   cards = filter_tool_cards(cards, "Pickaxe")
   
   # now get rid of all non-ore resources
   cards = drop_all_resources_except(cards, "Ore Vein")
   
   # must have pickaxe to get points for ore
   if !have_at_least_one(cards, "Pickaxe")
      cards = drop_all_of_type(cards, "Ore Vein")
   end
   
   # ore value is full for mountains, 1/2 for forest, 0 for plains
   if have_at_least_one(cards, "Mountain")
      # ore are full value
      cards.select { |card| card.type == "Ore Vein" }.each { |card| score += card.value }
   elsif have_at_least_one(cards, "Forest")
      # ore are half value (rounding up to be nice)
      cards.select { |card| card.type == "Ore Vein" }.each { |card| score += (card.value * 0.5).round }
   else
      # ore are worth zilch, boo
   end
   
   # drop all ore now
   cards = drop_all_of_type(cards, "Ore Vein")
   
   cards, score = score_horses_and_burros(cards, score)
   
   # all remaining cards are full value
   cards.each { |card| score += card.value }
   
   score
end

def score_homesteader_cards(cards)
   score = 0
   
   cards = filter_tool_cards(cards, "Plow")
   
   # now get rid of all non-seeds resources
   cards = drop_all_resources_except(cards, "Seeds")
   
   # must have pickaxe to get points for seeds
   if !have_at_least_one(cards, "Plow")
      cards = drop_all_of_type(cards, "Seeds")
   end
   
   # seed value is full for plains, 1/2 for forest, 0 for mountains
   if have_at_least_one(cards, "Plains")
      # full value
      cards.select { |card| card.type == "Seeds" }.each { |card| score += card.value }
   elsif have_at_least_one(cards, "Forest")
      # half value (rounding up to be nice)
      cards.select { |card| card.type == "Seeds" }.each { |card| score += (card.value * 0.5).round }
   else
      # seeds worth zilch, boo
   end
   
   # drop all seeds now
   cards = drop_all_of_type(cards, "Seeds")
   
   cards, score = score_horses_and_burros(cards, score)
   
   # homesteaders get double for ox
   cards.select { |card| card.type == "Ox" }.each { |card| score += (card.value * 2) }
   cards = drop_all_of_type(cards, "Ox")
   
   # all remaining cards are full value
   cards.each { |card| score += card.value }
   
   score
end

def score_trapper_cards(cards)
   score = 0
   
   cards = filter_tool_cards(cards, "Traps")
   
   # now get rid of all non-game resources
   cards = drop_all_resources_except(cards, "Wild Game")
   
   # must have traps to get points for game
   if !have_at_least_one(cards, "Traps")
      cards = drop_all_of_type(cards, "Wild Game")
   end
   
   # game value is full for forest, 1/2 for mountain, 0 for plains
   if have_at_least_one(cards, "Forest")
      # full value
      cards.select { |card| card.type == "Wild Game" }.each { |card| score += card.value }
   elsif have_at_least_one(cards, "Mountain")
      # half value (rounding up to be nice)
      cards.select { |card| card.type == "Wild Game" }.each { |card| score += (card.value * 0.5).round }
   else
      # wild game worth zilch, boo
   end
   
   # drop all game now
   cards = drop_all_of_type(cards, "Wild Game")
   
   cards, score = score_horses_and_burros(cards, score)
   
   # all remaining cards are full value
   cards.each { |card| score += card.value }
   
   score
end

def points_for_bonus_cards(cards)
   bonus_points = 0
   bonus_cards = cards.select { |card| Card.BONUSES().include? card.type }
   bonus_cards.each { |card| bonus_points += card.value }
   bonus_points
end

def remove_bonus_cards(cards)
   cards.reject{ |card| Card.BONUSES().include? card.type }
end

def main()
   begin
      puts "What type of pioneer are you? "
      pioneer_type = gets.chomp
      pioneer = Pioneer.new(pioneer_type)
   rescue StandardError
      puts "That's not a valid type of Pioneer at all! Try again!"
      retry
   end
   
   cards = []
   6.times do
      begin
         puts "Enter your next card type: "
         type = gets.chomp
         puts "Enter the card's point value: "
         value = gets.chomp.to_i
         card = Card.new(type, value)
         cards << card
      rescue StandardError
         puts "Hey, that's not a valid card! Try again!"
         retry
      end
   end
   pioneer.cards = cards
   
   score = score_cards(pioneer)
   puts "The value of your hand is: #{score}! Lucky you! (Now go refactor the code! :) )"
   
end

def getCards()
   
end

main()