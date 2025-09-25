require "telegram/bot"

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

class LocalVars
  def let name, value
    instance_variable_set var_name(name), value
  end

  def get name
    instance_variable_get var_name(name)
  end

  def set name, &block
    instance_variable_set var_name(name), block.call(get(name))
  end

  def var_name name
    "@#{name.to_s}"
  end
end

class Context
  def initialize message, user_state, bot
    @bot = bot
    @message = message
    @user_state = user_state
  end

  attr_reader :message, :user_state, :bot
end

class TelegramBotDialogTool
  def initialize bot
    @bot = bot
    @handlers = []
    @user_state = {}
    @state_stack = []
    @filter_stack = []
    @action_stack = []
  end

  def lets_rock &block
    instance_eval(&block)
  end

  def command name, state = nil, &block
    @state_stack << state if state

    filter_proc = Proc.new do
      message.text == "/#{name}"
    end
    @filter_stack << filter_proc
    
    filter = Proc.new { message.text == "/#{name}" }
    actions = []

    instance_eval(&block)
    @action_stack.each do |action|
      actions << action
    end

    @handlers << { filter: filter, actions: actions }

    @action_stack = []
    @state_stack = []
    @filter_stack = []
  end

  def say_text &block
    @action_stack << Proc.new do
      text = instance_eval(&block)
      @bot.api.send_message(chat_id: @message.chat.id, text: text)
    end
  end

  def say_hi
    # @action_stack << Proc.new do
    #   @bot.api.send_message(chat_id: @message.chat.id, text: "Hi #{@message.from.first_name} #{@message.from.last_name}!")
    # end
    say_text { "Hi #{message.from.first_name} #{message.from.last_name}!" }
  end

  def integer
    return State.new do
      validate do
        is_integer_regex?
      end
    end
  end

  def supply_message message
    case message
    when Telegram::Bot::Types::BotCommand
      puts "Command: ", message.command
    when Telegram::Bot::Types::Message
      puts "Пришло текстовое сообщение:", message.text
      if message.text[0] == "/"
        puts "Поскольку оно начинаеться с \"/\" то обрабатываем его как команду..."
        @handlers.each do |handler|
          ctx = Context.new message, @user_state, @bot
          filter = handler[:filter]
          if ctx.instance_eval(&filter)
            actions = handler[:actions]
            actions.each do |action|
              ctx.instance_eval(&action)
            end
          end
        end
      else
        puts "Обрабатываю как обычное сообшение..."
      end
    when Telegram::Bot::Types::CallbackQuery
      puts "Callback Query", message.callback_query
    end
  end
end
