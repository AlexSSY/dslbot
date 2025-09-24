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

class Context
  def initialize message, user_state
    @message = message
    @user_state = user_state
  end

  attr_reader :message, :user_state
end

class TelegramBotDialogTool
  def initialize
    @handlers = []
    @user_state = {}
    @state_stack = []
    @filter_stack = []
  end

  def lets_rock &block
    instance_eval(&block)
  end

  def command name, state = nil, &block
    byebug
    @state_stack << state if state

    filter_proc = Proc.new do
      message.text == "/#{name}"
    end
    @filter_stack << filter_proc
    
    @handlers << { filter: ->() { message.text == "/#{name}" }, block: block }
    
    instance_eval(&block)

    @state_stack = []
    @filter_stack = []
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
      puts "Пришло текстовое сообщение:", message.text
      if message.text[0] == "/"
        puts "Поскольку оно начинаеться с \"/\" то обрабатываем его как команду..."
      else
        puts "Обрабатываю как обычное сообшение..."
      end
    when Telegram::Bot::Types::CallbackQuery
      puts "Callback Query", message.callback_query
    end
  end
end
