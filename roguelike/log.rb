class Log

  def initialize
    $log = []
  end

  def self.add(log)
    $log << " #{$tick}: #{log} "
  end

  def self.all
    $log.reverse
  end

  def self.retrieve(num)
    $log.last(num).reverse
  end

end