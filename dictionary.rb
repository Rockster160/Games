class Dictionary
  class << self

    def lookup(word)
      words[word.downcase] || false
    end

    def words_at_length(n)
      words.select { |word| word.length == n.to_i }
    end

    def words
      @@_dictionary ||= File.read("/usr/share/dict/words").downcase.split("\n")
    end
  end
end
