# require 'pry-remote'

class Dictionary
  class << self

    def lookup(word)
      word_presence[word.downcase] || false
    end

    def words_at_length(n)
      word_presence.keys.select { |word| word.length == n.to_i }
    end

    def word_presence
      @@_dictionary ||= begin
        words = {}
        File.open("/usr/share/dict/words") do |file|
          file.each do |line|
            words[line.strip.downcase] = true
          end
        end
        words
      end
    end

    def difference_count_between_words(word1, word2)
      difference_count = 0
      word1.to_s.split("").each_with_index do |word1_char, char_idx|
        difference_count += 1 unless word1_char == word2.to_s[char_idx]
      end
      difference_count
    end

  end
end

class TransformError < StandardError; end
class WordTree

  def self.words_between(*words)
    tree = self.new(words)
    tree.find_branch_between_words
  end

  def self.valid_branch?(branches)
    previous_word = nil
    branches.all? do |word|
      if previous_word.nil?
        differences = 1 # Hack to achieve a valid first word
      else
        differences = Dictionary.difference_count_between_words(previous_word, word)
      end
      previous_word = word
      differences == 1
    end
  end

  def initialize(words)
    raise TransformError, "Must pass in 2 words to words_between." unless words.count == 2
    @start_word = words.first
    @end_word = words.last
    raise TransformError, "Words must have at least 1 character." unless @start_word.length >= 1
    raise TransformError, "Words must be the same length." unless @start_word.length == @end_word.length
    raise TransformError, "#{@start_word} is not in the dictionary." unless Dictionary.lookup(@start_word)
    raise TransformError, "#{@end_word} is not in the dictionary." unless Dictionary.lookup(@end_word)
    @current_dictionary = Dictionary.words_at_length(@start_word.length)
  end

  def find_branch_between_words
    @found = false
    @branch = []
    @max_difference = Dictionary.difference_count_between_words(@start_word, @end_word)

    @word_tree = {}
    @word_tree[@current_dictionary.delete(@start_word)] = build_branches_for_word(@start_word)

    compress_branch
    @branch
  end

  private

  def build_branches_for_word(trunk_word)
    @branch << trunk_word
    current_branch = {}
    branch_words = immediate_branches_from_word(trunk_word)
    branch_words.each do |branch_word|
      next if @found
      current_branch[branch_word] = build_branches_for_word(branch_word)
    end
    @branch.pop unless @found
    current_branch
  end

  def immediate_branches_from_word(trunk_word)
    branches = []
    @current_dictionary.each do |dictionary_word|
      next if @branch.include?(dictionary_word)
      next if Dictionary.difference_count_between_words(@start_word, dictionary_word) > @max_difference

      difference_count = Dictionary.difference_count_between_words(trunk_word, dictionary_word)

      if difference_count == 1
        branches << dictionary_word
        if dictionary_word == @end_word
          @found = true
          @branch << @end_word
        end
      end
    end
    branches
  end

  def compress_branch
    return unless @branch.any?
    copybranch = @branch.dup

    until (current_word ||= @first_word) == @end_word
      diff_branch = copybranch.map do |word|
        Dictionary.difference_count_between_words(current_word, word)
      end
      current_word_idx = copybranch.index(current_word)
      next_word_idx = diff_branch.rindex(1)
      if current_word_idx && next_word_idx
        useless_words = copybranch[current_word_idx + 1..next_word_idx - 1]
        copybranch -= useless_words
      end
      current_word = copybranch[current_word_idx.to_i + 1]
    end

    @branch = copybranch
  end

end

if Object.const_defined?("RSpec")
  RSpec.describe do

    context "helper methods" do
      context "for WordTree" do
        context "valid_branch?" do
          it "returns true when each word is 1 character difference than the one before it" do
            branches = ["hit", "hot", "dot", "dog", "cog"]

            expect(WordTree.valid_branch?(branches)).to be(true)
          end

          it "returns false when the words are more than 1 character apart" do
            branches = ["hit", "dog"]

            expect(WordTree.valid_branch?(branches)).to be(false)
          end
        end
      end

      context "for Dictionary" do
        context "lookup" do
          it "returns a boolean of whether the word exists" do
            expect(Dictionary.lookup("notarealword")).to be(false)
            expect(Dictionary.lookup("word")).to be(true)
          end
        end

        context "difference_count_between_words" do
          it "returns a number showing how many characters are different between 2 words" do
            expect(Dictionary.difference_count_between_words("bathe", "cubes")).to eq(5)
            expect(Dictionary.difference_count_between_words("tree", "free")).to eq(1)
            expect(Dictionary.difference_count_between_words("drink", "drink")).to eq(0)
          end
        end
      end
    end

    context "fails to words_between" do
      it "should return an empty array" do
        branches = WordTree.words_between("formaldehydesulphoxylate", "pathologicopsychological")
        expect(branches).to match_array([])
      end
    end

    context "succeeds transformation" do
      it "should return a list of words beginning with the start and ending with the end words" do
        branches = WordTree.words_between("hit", "cog")
        expect(branches.first).to eq("hit")
        expect(branches.last).to eq("cog")
      end

      it "should return a list of words that are each different by a single character" do
        branches = WordTree.words_between("hit", "cog")
        expect(WordTree.valid_branch?(branches)).to be(true)
      end
    end

    context "should raise an error" do
      it "if the wrong number of words are given" do
        expect{WordTree.words_between("sup")}.to raise_error("Must pass in 2 words to words_between.")
        expect{WordTree.words_between("sup", "dog", "tic")}.to raise_error("Must pass in 2 words to words_between.")
      end

      it "if the strings are blank" do
        expect{WordTree.words_between("", "")}.to raise_error("Words must have at least 1 character.")
      end

      it "if words are different lengths" do
        expect{WordTree.words_between("this", "other")}.to raise_error("Words must be the same length.")
      end

      it "if word isn't in the dictionary" do
        expect{WordTree.words_between("tree", "eert")}.to raise_error("eert is not in the dictionary.")
        expect{WordTree.words_between("eert", "tree")}.to raise_error("eert is not in the dictionary.")
      end
    end
  end

elsif ARGV.count == 2
  WordTree.words_between(ARGV[0], ARGV[1])
else
  binding.pry
end
