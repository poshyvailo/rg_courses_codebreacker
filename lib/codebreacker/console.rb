class Console

  def initialize
    @phrases = YAML.load_file(File.expand_path('../..lib/codebreacker/data/phrases.yml', __dir__))
    puts_message :hello
    puts_message :rules
    print_menu
  end

  def print_menu
    puts_message :menu
    choice = ask :ask_menu
    print_menu unless %w[start exit stat].include? choice.downcase
    case choice
      when 'start' then start
      when 'stat' then show_stat
      else exit
    end
  end

  def show_stat
    puts generate_stat
    print_menu
  end

  def start(player_name = nil)
    game_mode = select_game_mode
    player_name = player_name ? player_name : set_player_name

    @game = Game.new player_name, game_mode == '' ? game_mode : :normal
    puts_message :start_game, @game.attempts, @game.hints
    check_guess
  end

  def set_player_name
    player_name = ask :ask_name
    if player_name.empty?
      puts_message :wrong_name
      set_player_name
    end
    player_name
  end

  def select_game_mode
    puts_message :game_mode
    game_mode = ask :ask_game_mode
    game_mode.to_sym
  end

  def check_guess
    guess = ask :ask_code
    show_hint if guess.downcase == 'hint'
    wrong_guess unless @game.valid_code? guess
    guess_result = @game.make_guess(guess)
    check_game_status
    puts_message :try_again, guess_result.inspect, @game.attempts
    check_guess
  end

  def check_game_status
    game_result @game.status if %w[win lose].include? @game.status.to_s
  end

  def show_hint
    if @game.hints > 0
      puts_message :hint, @game.show_hint, @game.hints
    else
      puts_message :no_hint
    end
    check_guess
  end

  def game_result(status)
    puts_message status, @game.secret_code
    save_statistic
    play_again
  end

  def play_again
    answer = ask :ask_play_again
    play_again unless %w[y n].include? answer
    answer == 'y' ? start(@game.player.to_s) : exit
  end

  def wrong_guess
    puts_message :wrong_guess
    check_guess
  end

  private

  def save_statistic
    data = {
        name: @game.player.to_s.to_sym,
        mode: @game.game_mode.to_sym,
        ststus: @game.status.to_sym
    }
    Statistic.insert(data)
  end

  def generate_stat
    data_stat = Statistic.load
    string = "STATISTIC\n"
    string << "#{'-' * 60}\n"
    data_stat.each_pair do |name, data|
      string << "#{name.to_s}\n"
      string << "#{'-' * 60}\n"
      data.each_pair do |mode, stat|
        string << "#{mode.to_s.capitalize}\t|\t"
        string << "#{stat[:win]}\t|\t"
        string << "#{stat[:lose]}\t|\t"
        string << "#{stat[:last_game]}\n"
      end
      string << "#{'-' * 60}\n"
    end
    string
  end

  def puts_message(key, *test)
    text = "#{message key}" % test
    puts text
  end

  def ask(message_key = nil)
    print message(message_key), ' ' unless message_key.nil?
    gets.chomp
  end

  def message(key)
    @phrases[key.downcase.to_sym]
  end

end
