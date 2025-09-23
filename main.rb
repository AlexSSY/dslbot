require "byebug"
require "dotenv/load"
require_relative "db"

birthday = StateGroup.new do
  field :year, ask: "Year?"
  field :month, ask: "Month?"
  field :day, ask: "Day?"

  validates :year, ->(value) { value.kind_of? Integer ? nil : "Value is not valid integer" }
  validates :year, ->(value) { value > 1000 ? nil : "Value must be greater than 1000" }
end

profile = StateGroup.new do
  field :first_name, ask: "First name?"
  field :last_name, ask: "Last name?"
  field :birth_day, states: birthday, ask: "Birthday?"
  field :gender, ask: "Send your gender male/female", reply: ["male", "female"]
end

class DateState < StateGroup
  positive_integer :year # ".../date/year"
  positive_integer :month # ".../date/month"
  positive_integer :day # ".../date/day"
end

# string так же как и positive_integer подразумевают базовую валидацию
class AnimalState < StateGroup
  string :name # ".../animal/name"
  positive_integer :age # ".../animal/age"
  date :birthday, group: DateState
end

TelegramBotDialogTool.lets_rock do

  command :start do
    say_hi
  end

  # Здесь в стек ложиться (для текушего пользователя)
  # "/add"
  command :add, scope: :user do
    compose_animal do |animal_state|
      if animal_state.valid?
        Animal.create! animal_state.to_h
        say "The new animal saved successfully."
      else
        say "The new animal not saved."
        say animal_state.errors
      end
    end
  end
  
  # в этом блоке задаються состояния которые хранятся opposite user
  scope :user do

    # здесь мы пишем: проверяй текст на match з регуляркой которая 1 аргументом
    # infact этот метод уже записывает состояние (в данн. случае 'user-scope')
    # это состояние должно приводить к тому что следующий матчинг будет производиться внутри этого блока
    # если таковые указанны. А если же не указанны мы должны игнорировать этот блок впринципе
    match_text /d+/ do
      answer "Cool. You send me a random number"

      # let позволяет хранить переменную с привязкой к scope
      # +
      # get(:attempts)
      # set(:attempts) { |attempts| attempts - 1 }
      let(:quest_number) { 23 }
      try 3.times do
        send "Try to figure out my number:"
        number = positive_integer
        if get(:quest_number) == number
          answer "Congrats!"
          leave
        end
      end
      answer "Sorry you do not figure out."
    end

  end

end

if __FILE__ == $0
  puts "Hello World!"
end
