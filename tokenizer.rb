class Tokenizer
  attr_accessor :stored_strings, :token

  def initialize(full_str)
    @unwrap = nil
    @stored_strings = []
    @token = loop {
      gen = [*(0..9), *("a".."z"), *["A".."Z"]].sample(10).join
      break gen unless full_str&.include?(gen)
    }
  end

  def tokenize!(full, regex)
    full.gsub!(regex) do |found|
      @stored_strings << found
      "#{@token}..#{@stored_strings.length-1}.."
    end
  end

  def untokenize!(full)
    @stored_strings.each_with_index do |stored, idx|
      full.gsub!("#{@token}..#{idx}..", stored)
    end
    full
  end
end
