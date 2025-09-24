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

module Filters
  def command command
    message.text == command
  end

  def state state
    user_state == state
  end
end

class Context
  def initialize message, user_state
    @message = message
    @user_state = user_state
  end

  attr_reader :message, :user_state
end

class Handler
  def initialize message_type, filter, &block
    @message_type = message_type
    @filter = filter
  end

  attr_reader :filter

  def check_filter context
    context.instance_eval(&filter)
  end
end

class TelegramBotDialogTool
  class << self
    @stateless_handlers = []
    @user_state_handlers = {}
    @user_state = {}

    def lets_rock &block
      instance_eval(&block)
    end

    def command name, state = nil, &block
      if state
        # TODO: add logic later
      else
        # handler = Handler.new 
        # @stateless_handlers
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
      case message
      when Telegram::Bot::Types::BotCommand
        puts "Command: ", message.command
      when Telegram::Bot::Types::Message
        binding.irb
        puts "Message:", message.text
      when Telegram::Bot::Types::CallbackQuery
        puts "Callback Query", message.callback_query
      end
    end
  end
end
