require "byebug"
require "dotenv/load"
require_relative "db"
require_relative "state_group"

# tgd = TelegramBotDialogTool.new
# tgd.lets_rock do

#   command :start do
#     say_hi
#   end

  # command :add, "new_user" do
  #   ask string, for: :first_name, with: "Enter First Name:"
  #   ask string, for: :last_name, with: "Enter Last Name:"
  #   answer "New user \"#{get(:first_name)} #{get(:last_name)}\" added."
  # end

  # Здесь в стек ложиться (для текушего пользователя)
  # "/add"
  # command :add, scope: :user do
  #   compose_animal do |animal_state|
  #     if animal_state.valid?
  #       Animal.create! animal_state.to_h
  #       say "The new animal saved successfully."
  #     else
  #       say "The new animal not saved."
  #       say animal_state.errors
  #     end
  #   end
  # end
  
  # в этом блоке задаються состояния которые хранятся opposite user
  # scope :user do

    # здесь мы пишем: проверяй текст на match з регуляркой которая 1 аргументом
    # infact этот метод уже записывает состояние (в данн. случае 'user-scope')
    # это состояние должно приводить к тому что следующий матчинг будет производиться внутри этого блока
    # если таковые указанны. А если же не указанны мы должны игнорировать этот блок впринципе
    # match_text /d+/ do
    #   answer "Cool. You send me a random number"

      # let позволяет хранить переменную с привязкой к scope
      # +
      # get(:attempts)
      # set(:attempts) { |attempts| attempts - 1 }
  #     let(:quest_number) { 23 }
  #     try 3.times do
  #       send "Try to figure out my number:"
  #       number = positive_integer
  #       if get(:quest_number) == number
  #         answer "Congrats!"
  #         leave
  #       end
  #     end
  #     answer "Sorry you do not figure out."
  #   end

  # end

# end

if __FILE__ == $0
  require 'telegram/bot'

  token = ENV["BOT_TOKEN"]

  Telegram::Bot::Client.run(token) do |bot|
    tgd = TelegramBotDialogTool.new bot
    tgd.lets_rock do
      command :start do
        say_text {
          <<~TEXT
            Hello #{message.from.first_name} #{message.from.last_name}!
            Your ID: #{message.from.id}
          TEXT
        }
      end

      command :add, "new_user" do
        ask string, for: :first_name, with: "Enter First Name:"
        ask string, for: :last_name, with: "Enter Last Name:"
        answer "New user \"#{get(:first_name)} #{get(:last_name)}\" added."
      end
    end
    bot.listen do |message|
      tgd.supply_message message
    end
  end
end
