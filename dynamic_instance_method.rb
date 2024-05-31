class Thing
  def self.register(method_name, &block)
    define_method(method_name) do |*args|
      block.call(self, *args)
    end
  end
end

Thing.register(:dot) do |item, x, y|
  puts "Item: #{item}, x: #{x}, y: #{y}"
end

thing = Thing.new

thing.dot(5, 10)
