require "telegram/bot"
require "byebug"

module ValidationMethods
  def is_integer_regex?(str)
    str.match?(/\A[-+]?\d+\z/)
  end
end

class State
  def initialize name, validators=[]
    @name = name
    @validators = validators
  end

  attr_reader :name
  attr_reader :validators

  include ValidationMethods
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

class TelegramBotDialogTool
  class << self
    @root_handlers = []
    @user_state = {}
    @global_state = {}

    def lets_rock &block
      instance_eval(&block)
    end

    def command name
      @root_handlers << { type: :text, filter: "/#{name}" }
    end

    def say_hi
      
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
