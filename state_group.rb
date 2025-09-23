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

class StateGroup
  include Validation

  def initialize &block
    @command_handlers = {}
    @message_handlers = {}
    instance_eval &block
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
    @state.validators.each do |validator|
      error = validator.call(@value)
      yield error if !error
    end
  end
end

class TelegramBotDialogTool
  class << self
    def lets_rock &block
      instance_eval &block
    end

    def command name
    
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
