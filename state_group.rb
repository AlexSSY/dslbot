require "telegram/bot"

module Validation
  @validators = {}
  
  def validates name, callback
    validators[name]
  end

  def is_integer_regex?(str)
    str.match?(/\A[-+]?\d+\z/)
  end

  def validate name, value
    
  end
end

class State
  def initialize name, validators=[]
    @name = name
    @validators = validators
  end

  attr_reader :name
  attr_reader :validators
end

class BoundState
  def initialize state, value
    @state = state
    @value = value
  end

  def errors
    return enum_for(:errors) unless block_given?

    @state.validators.each do |validator|
      error = validator.call(@value)
      yield error if error # отдаем только ошибки
    end
  end

  def valid?
    errors.none?
  end
end

class TelegramBotDialogTool
  class << self
    def lets_rock &block
      instance_eval(&block)
    end

    def command name
    
    end

    def say_hi
      
    end

    def state state_group, &block
      state_group.instance_eval &block
    end

    def update message
      case message
      when Telegram::Bot::Types::BotCommand
        puts 'command'
      when Telegram::Bot::Types::Message
        puts 'message'
      when Telegram::Bot::Types::CallbackQuery
        puts 'callback query'
      end
    end
  end
end
