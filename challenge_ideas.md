LinkedList (Library Reservation)
Tree Recursion (Self Referential)

Konami code to trigger secret event on a web page

Cards - 5 Card Draw + exchange cards + win detection
√ Numbers - Random generation with weights
Words - Transformation
√ Colors - Fade from one color to other OR Color Mapper
Wordle/Mastermind

Free search parser
  in:archive name::Rocco notes~pull
  * Expand into hash
  * If multiple of the same thing (name:Rocco name:Luffy) auto do an OR between these two
    * Otherwise everything does AND

| A plane has 100 seats and 100 passengers. Each passenger has a assigned seat indicated on their boarding pass. The first passenger to board the plane has lost their boarding pass and, therefore, chooses a seat at random. Every subsequent passenger boards the plane and either sits in their assigned seat if it's available or chooses a random unoccupied seat if their seat is already taken. What is the probability that the last passenger to board the plane will end up in their assigned seat?

RoboMouse
Endpoint that you can Ping to start, and responds with available directions.
Can then send another request with a given Direction (LRSB), and response will be next available directions (LRSB)
Meta data should include the number of moves made and whether or not the current position is the goal or not.
Store the map and the current coord server side somehow.

Gaming App
  Incorporated Algorithm and data structures into a game for mobile apps
  Implemented 10 levels that enables users to win prizes
  Added customization features for the users' characters
Portfolio Website
  Designed online album that shows screen captures of built programs
  included a description of each programs' purpose and features
  added a submission field for people to submit inquiries
Social Media App
Food Tracker
  Calculator for nutritional vals
Transportation App
  Maps integration
  Traffic detection
Retail App
  Buy/Sell Items
  Submit questions to seller
  Search engine
Recommendation
  Gives book ideas based on submitted preferences
Payment App
  Send/request money from users
  Track finances
  Save contacts

1. Dungeon Room Generator
  Create a class to generate randomized “dungeon rooms” for a text-based adventure game. Each room can:
  	•	Randomly include items (like a “sword,” “shield,” or “potion”) and obstacles (like “spikes” or “locked doors”).
  	•	Allow movement in one or more directions (north, south, east, west).
  	•	Have a describe method to print a room description based on its contents and available exits.
  	•	Bonus: Connect rooms so you can travel between them.
2. Weather Forecaster
  Write a “weather forecaster” that uses random weather patterns but makes them feel somewhat realistic:
  	•	Track and print a 5-day forecast, with conditions like “sunny,” “rainy,” or “cloudy.”
  	•	Temperatures should vary within a reasonable range based on the previous day’s forecast.
  	•	Include a method to display the forecast in a friendly format.
3. Potion Mixing Simulator
  Create a simple alchemy system for mixing potions! Each potion has:
  	•	A unique effect (e.g., “healing,” “strength boost”) and strength (randomized).
  	•	Ingredients that you can randomly combine. If the combination is “correct,” you get a stronger effect; if it’s wrong, you get a “poison.”
  	•	A mix method that lets you experiment with different combinations and returns a “potion” or a “failure.”
    •	Potion Shop Reputation: The more potions the player successfully creates, the higher their reputation, which could lead to rarer ingredients or recipe hints.
    •	Experimental Effects: For added fun, each mixing attempt could have a chance of producing an unintended side effect, like a color change, sparkles, or an aroma that attracts (or repels) customers.
    •	Potion Storage: Add an expiration mechanic where potions lose strength over time, encouraging the player to mix fresh batches.
    1.	Ingredient List:
    •	Define a list of magical ingredients, each with properties that affect the potion’s outcome.
    •	Each ingredient could have a type (e.g., “herb,” “mineral,” “liquid”) and an effect (e.g., “healing,” “strength boost,” “mana boost”).
    •	Examples: Eye of Newt, Dragon Scale, Moon Dew, Phoenix Feather, Goblin Tears.
    2.	Recipe Logic:
    •	Create predefined recipes that the player can discover by experimenting. For instance, combining Eye of Newt with Moon Dew might create a “Healing Potion.”
    •	Each recipe could have a specific combination of ingredients (type, order, quantity) required to succeed.
    •	If the ingredients don’t match a known recipe, it produces a random “failure” result with a small chance of creating a rare potion.
    3.	Mixing Potions:
    •	Allow players to combine up to three ingredients in a single potion.
    •	Provide feedback on the result, like “You’ve created a Weak Healing Potion!” or “Your concoction fizzles out into a smelly sludge.”
    •	Track successful potions in an inventory, which could later be “sold” for profit or used for special effects (e.g., a rare potion boosts your mixing skill).
    4.	Potion Effects:
    •	Each successful potion should have an effect and a strength level, e.g., a “Healing Potion” that heals 20 HP or a “Mana Elixir” that restores 50 MP.
    •	Failure potions could have amusing or random effects, like causing the user to sneeze uncontrollably or turn a random color.
    5.	Rarity and Power:
    •	Introduce rarities for potions: Common, Rare, Legendary. The rarer the potion, the stronger the effect and the higher its selling price.
    •	Each mixing attempt could have a small chance to create a legendary potion if the ingredients are “close” to a known recipe.
    6.	Random Events and Discoveries:
    •	Occasionally, the game could throw in a random event, like finding a new recipe page or a mysterious ingredient that temporarily increases potion power.
    •	Each potion mix might have a chance of yielding new clues about combinations, leading to more successful concoctions.
4. Pet Tamagotchi
  Build a virtual pet that you can interact with! The pet should:
  	•	Have basic needs like hunger, happiness, and energy that change over time.
  	•	Provide methods like feed, play, and rest to meet these needs.
  	•	If neglected, it gets sad, and if well-taken care of, it’s happy!
  	•	Bonus: Add randomness to its behavior (it might refuse to eat sometimes or randomly get tired).
5. Treasure Map
  Design a “treasure map” grid where each cell can either contain treasure, an obstacle, or be empty.
  	•	Provide a generate_map method to create a randomized map with treasure scattered around.
  	•	Allow “digging” at a specific cell to check if there’s treasure there.
  	•	Include a way to track which cells have been dug up already and display a summary of the total treasure found so far.


Ruby concepts:
  Adding custom methods inside of blocks. Use Engine::Pencil for reference

Routes.configure do
  get :path # <-- Where does this come from??
end



Machine Learning?
  Given a large set of random numbers (10k, for example)
    Create an algorithm that generates roughly the same generation lines
      (For example, the 10k numbers create a bell curve- write a function that generates numbers that fall on the same bell curve)



Neat things in Ruby:
  o[x] on an object is the same as calling o.call(x)
    * Can use this for calling procs
    * Technically could also use this for CallableService objects (Not recommended)
  You can redefine "method_missing" to allow calling any method on an object
    * Can be used to delegate instance methods to class methods
    * Used in svg.rb to allow setting any attributes on an instance
  When interpolating an object, `.to_s` is called.
    * You can redefine that method to give it a custom display to show
  When calling an object in the console/irb, `.inspect` is automatically called on it.
    * This can trigger queries to execute
    * You can redefine `.inspect` to return a helpful piece of data for your custom classes
  Can define <<, +, and other similar operator methods on objects
    * Allows you to call `MyClass.new + MyClass.new` to perform custom logic
  Blocks with args by default define _1, ..._n for block params so you don't have to define them
    * Bad practice, but a neat thing to know of.


sd random_topic
sd random_topic Math

# Challenge Ideas
Refactor some inefficient code
Find bug in code
Minify
Short & Sweet, but learning something new (like binary ops)

Lightning Talk:
  Screen Clear
  Live keys
  Colors in terminal

Fractal
Music generator: This could involve building a program that generates random music using simple rules like a Markov chain or a genetic algorithm.
Connect4
Recursive (Factorial or Fibonacci)
Search algo? - linear search or binary search, which are fundamental algorithms in computer science.
Machine learning
* Detect algo for bell curve/random gen plot
* Predict house price using linear regression
Implement a graph traversal algorithm like breadth-first search or depth-first search to solve a problem like finding the shortest path between two nodes in a graph.
Multithreading?
Implement a binary search algorithm for a sorted array of integers.
Create a program that generates a random maze and solves it using a depth-first search algorithm.
Meta Programming
FourIsMagic
Kaprekar's Constant
* Take 4 digit number, subtract asc nums from desc nums
Towers of Hanoi
Snake
Text Editor (in terminal)
Hangman
Text/Morse Translator
LightsOut
Palindrome
Breadboard?
Make Change
  * Take a dollar amount ($52.13) and return a hash containing the number of bills/coins to make that value
Word reverser (from sentence)
  * Hello, World! => olleH, dlroW!
Write own language (parsed by Ruby/JS)
JSON
  * Parse
  * pretty print
  * Colorize
  * v2 json - keys don't need quotes
  * Include parsing from a Ruby hashrocket syntax
Tic Tac Toe
  * Add a CPU player
  * Winning detection
  * Smart CPU
Paint (HTML or terminal?)
Color - fade from one to the other
Scrape website and do something with data
  * Reddit - pull text?
    * Or pull comments and show them nested in term
  * Some random insecure website, log in, pull some data
Cipher
  * Default cipher, when given a key and string, spits out a value
  * Can be used to decipher as well
  * Adv: Able to extend the object with custom Ciphers
ASCII Table
Draw a line between 2 points on a grid. (Pixel art/movement-one space at a time)
Wordle
  * Given a word, highlight which letters as B/Y/G
  * Helper
    * Enter guesses
      * Show * based options
      * Show All possible values
      * Cross match with dictionary to find possible actual words
  * Solver
    * Use helper to select words
    * Compete to see who's solver works best over a handful of randomly chosen words (Using previous Wordle words)
Hash Branches - turn nested hash into dot separated with values
Cards
  * Deck + Shuffle
  * Deal 5 cards to players, let them exchange cards
  * Texas Holdem winning detection
  * Add jokers?
Chess
Pacman
Tetris
Web Scraper
  * Scrape data from a website and display it / collect the data in a useful way
Mixed Numbers
Roman Numeral parse to/from
Colorize
  * String
  * RGB/hex to color
GoL
  * Runner
  * Able to affect the board (pause and modify cells by coord?)
  * Detect if a board is stable (1 frame, <10 frame, inf frame) (Show how many frames are repeating)
  * Given a board, determine how many iterations until stable (1 frame)
  * Given a board, determine how many iterations until stable (multi frame)
CellularAutomata (https://en.wikipedia.org/wiki/Wireworld) wire - 3 states, dead, live, hot.
  * Live becomes hot after 1 turn
  * Hot becomes dead after 1 turn
  * Dead becomes live if there is exactly 1 or 2 live cells next to it.
AutomataCave
Bowling
  * Given a string of frames "X X 9/ 5-"...
  * Show the score of the game
SVG generator
Custom DB/ORM
Color Mapper
  * Given a set of ranges per color, generate a color based on a given value
  (Temperature fader - red is 100, green is 70, blue is 32, white is 0)
Anonicon generator
  * Generate an SVG using an identifier (ip, username, etc...)
  * Should be recognizable as an anonicon (2 are unique, but you can tell they're from the same place)
Mover Puzzle
  * Given a list of directions (L -> Left, R -> Right, U -> Up, D -> Down)
  * "LDLUUR"
  * Determine if the end result is the same location as the beginning.
JSChance
Ruby/Terminal "game" (Movement with live keys)
  * Basic movement
  * Boxes (Push boxes into "hole")
  * Spells/fighting?
  * Enemies
Scale between values (5 in 1-10 maps to 50 in 1-100)
Pathfinding
  * Through a maze / Maze Solver / A*
  * Shortest route in open room with obstacles
  *
Weighted Number generation
Terrain Generation (Perlin Noise, wave function collapse)
Maze Generator (solid/grid)
Maze GAME
 * Generate a maze and give to a "player" - the player can only see 2(?) spaces in each direction. The whole maze is "dark" until a player has visited the area- then the map stays lit for future reference
 * Maybe show the end of the maze?
 * Don't show or hint towards edges
Implementing Algorithms
  * Create method that computes using an algorithm
    * Normal Distribution
      * min, max, bias, height
    * Gold's Formula (Strength of ice) -- http://lakeice.squarespace.com/bearing-strength/#:~:text=Arithmetic%3A,to%20as%20'Gold's%20Formula
      * P=Ah^2
      * P=CFh^2
      P is the load
      h is the thickness of the ice sheet
      A is a constant which has units like pounds per square inch (psi), tons/square inch,  kg/cm2 or pascals (newtons/ square meter).  For this discussion we will use units of pounds and inches.  The numeric value of A can easily be converted to different units.
      C is a proportionality constant between flexural strength and bearing strength
      F is the flexural strength as measured in simple beam tests with the top in tension
    * Compound Interest
      * A = P(1 + r/n)nt
      A = Accrued amount (principal + interest)
      P = Principal amount
      r = Annual nominal interest rate as a decimal
      R = Annual nominal interest rate as a percent
      r = R/100
      n = number of compounding periods per unit of time
      t = time in decimal years; e.g., 6 months is calculated as 0.5 years. Divide your partial year number of months by 12 to get the decimal years.
      I = Interest amount
      ln = natural logarithm, used in formulas below
