# cheap initial pass at a class representing the 'classes' (cowboy, etc) - calling them 'pioneers'
# David Kapp
# Licensed under the nobody-gives-a-damn-so-it's-free-for-all(TM) license

class Pioneer
   attr_accessor :cards, :profession
   
   def self.VALID_PIONEER_TYPES
      ["Cowboy", "Prospector", "Homesteader", "Trapper"]
   end
   
   def initialize(profession, cards = [])
      @profession = profession.downcase().capitalize
      if !Pioneer.VALID_PIONEER_TYPES.include? @profession
         raise StandardError.new("#{@profession} is not a valid profession type!")
      end
      @cards = cards
   end
   
end