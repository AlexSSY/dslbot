class DB
  def initialize
    @storage = {}
    @index_key = Fiber.new do
      i = 0
      loop do
        Fiber.yield i
        i += 1
      end
    end
  end

  @instance = new

  private_class_method :new

  class << self
    def instance
      @instance
    end
  end

  def save data
    @storage[@index_key.resume] = data
  end

  def get index
    @storage.fetch index, nil
  end

  attr_reader :storage
end