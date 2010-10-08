# cheap initial pass at a class representing the cards
# David Kapp
# Licensed under the nobody-gives-a-damn-so-it's-free-for-all(TM) license

class Card
   # type is something like "plains", "horse", etc
   # value is the numerical value
   attr_accessor :type, :value
   
   class << self
      def LANDS
         ["Plains", "Forest", "Mountain"]
      end
      
      def TOOLS
         ["Lasso", "Pickaxe", "Plow", "Traps"]
      end
      
      def RESOURCES
         ["Cattle", "Ore Vein", "Seeds", "Wild Game"]
      end
      
      def BEASTS
         ["Horse", "Burro", "Ox"]
      end
      
      def BONUSES
         ["Circus", "Guitar", "Opera House", "Railroad", "Rifle", "Whiskey"]
      end
      
      def VALID_CARD_TYPES
         LANDS() + TOOLS() + RESOURCES() + BEASTS() + BONUSES()
      end
   end
   
   def initialize(type, value)
      # we don't want to deal with the difference between Cowboy and cowboy - make everything consistent
      # this gets weird due to multi-word things like "ore vein" - hence the long command
      @type = type.downcase.split(" ").each { |word| word.capitalize! }.join(" ")
      if !Card.VALID_CARD_TYPES.include? @type
         raise StandardError.new("#{@type} is not a valid card type!")
      end
      @value = value
   end
   
end