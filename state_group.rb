require "telegram/bot"
require "byebug"

module Validation
  @validators = []

  def is_integer_regex?
    @value.match?(/\A[-+]?\d+\z/)
  end

  def validate &block
    @validators << block
  end

  attr_reader :validators
end

class State
  def initialize name, &block
    @name = name
    instance_eval(&block)
  end

  attr_reader :name

  include Validation
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
      yield error if error
    end
  end

  def valid?
    errors.none?
  end
end

class Handler
  def initialize context, filter, &block
    
  end 
end

class Handlers
  @handlers = []

  def <<
    
  end
end

class TelegramBotDialogTool
  class << self
    @stateless_handlers = Handlers.new
    @user_state_handlers = Handlers.new
    @user_state = {}

    def lets_rock &block
      instance_eval(&block)
    end

    def command name, state = nil, &block
      if state
        @stateless_handlers.instance_eval(&block)
      else
        @stateless_handlers.instance_eval(&block)
      end
    end

    def say_hi
      Proc.new do
        @bot.api.send_message(chat_id: @message.chat.id, text: "Hi #{@message.from.full_name}!")
      end
    end

    def integer
      return State.new do
        validate do
          is_integer_regex?
        end
      end
    end

    def filter_exact value, value1
      value == value1
    end

    def supply_message message
      byebug
      user_id = message.from.id

      case message
      when Telegram::Bot::Types::BotCommand
        puts 'command'
      when Telegram::Bot::Types::Message
        current_user_state = @user_state.fetch user_id
      when Telegram::Bot::Types::CallbackQuery
        puts 'callback query'
      end
    end
  end
end
