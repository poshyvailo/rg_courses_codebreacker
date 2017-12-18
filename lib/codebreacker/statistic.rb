class Statistic

  FILE = './lib/codebreacker/data/statistic.yml'

  def self.show
    load
  end

  def self.insert(data)
    file = load

    if file[data[:name]].nil?
      file[data[:name]] = create_new_record
    end

    player_data = file[data[:name]][data[:mode]]
    data[:status] == :win ? player_data[:win] += 1 : player_data[:lose] += 1
    player_data[:last_game] = Time.now
    save(file)
  end

  def self.create_new_record
    {
        :easy => {win: 0, lose:0, last_game: nil},
        :normal => {win: 0, lose:0, last_game: nil},
        :hard => {win: 0, lose:0, last_game: nil},
    }
  end

  private

  def self.load
    YAML.load_file(FILE)
  end

  def self.save(data)
    File.write(FILE, data.to_yaml)
  end

end