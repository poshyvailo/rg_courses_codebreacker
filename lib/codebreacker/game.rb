class Game

  attr_reader :status, :attempts, :hints, :secret_code, :player, :game_mode

  def initialize(player_name, game_mode = :normal)
    @secret_code = generate_secret_code
    set_game_mode game_mode
    @status = :play
    @game_mode = game_mode.to_s
    @player = Player.new(player_name)
  end

  def make_guess(guess)
    raise(ArgumentError, "Invalid guess code #{guess}") unless valid_code? guess
    result = check_guess(guess)
    player_win if result == '++++'
    player_lose if @attempts == 0
    remove_attempt
    result
  end

  def to_s
    status = @status == :win ? '1|0' : '0|1'
    "#{@player.to_s}|#{@game_mode}|#{status}|#{Time.now}"
  end

  def valid_code?(code)
    /^[1-6]{4}$/.match code.to_s
  end

  alias :valid_guess? :valid_code?

  def show_hint
    remove_hint
    num = rand(@secret_code.size - 1)
    hint = @secret_code.dup.chars.map.with_index do |char, index|
      index == num ? char : '#'
    end
    hint.join
  end

  private

  def set_game_mode(game_mode)
    game_modes = YAML.load_file(File.expand_path('../../lib/codebreacker/data/game_mods.yml', __dir__))
    unless %w[easy normal hard].include? game_mode.to_s
      raise(ArgumentError, 'Game mode must be "easy", "normal" or "hard:')
    end
    @attempts = game_modes[game_mode][:attempts]
    @hints = game_modes[game_mode][:hints]
  end

  def check_guess(guess)
    guess_copy = guess.dup
    code = @secret_code.dup

    guess_copy.chars.each.with_index do |guess_number, guess_index|
      if guess_number == code[guess_index]
        guess_copy[guess_index], code[guess_index] = '+', '+'
      end
    end

    guess_copy.chars.each.with_index do |guess_number, guess_index|
      next if guess_number == '+'
      if code.index(guess_number)
        guess_copy[guess_index], code[guess_number] = '-', '-'
      end
    end

    guess_copy.delete('1-6').chars.sort.join
  end

  def remove_attempt
    @attempts -= 1 if @attempts != 0
  end

  def remove_hint
    @hints -= 1 if @hints != 0
  end

  def player_lose
    @status = :lose
  end

  def player_win
    @status= :win
  end

  def generate_secret_code
    Array.new(4) {rand(1..6)}.join
  end

end
