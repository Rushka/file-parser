require 'date'

class FileParser
  TYPES = %w[account activity position security]

  REG_ID   = /U[0-9]+/
  REG_DATE = /[0-9]{8}/

  def initialize(list)
    @list = Dir.glob(list)
    @result = {}
  end

  def start
    @list.each do |file_path|
      File.open(file_path, 'r') do |file|
        p file.read
      end
    end
  end

  def first_file
    File.open(@list.first, 'r') do |file|
      accounts = file.read.split(/\n/)
      accounts.map do |line|
        if valid_line? line
          @line = line

          find_or_create_id 
          find_or_create_date
          # find_or_create_type
        end
      end

      p @result
    end
  end

  private
  def find_or_create_id
    match = @line.match(REG_ID)[0]
    @current_id = @result[match] ||= {} 
  end

  def find_or_create_date
    @line.scan(REG_DATE) do |date_string|
      date = str_to_date(date_string)
      next unless date
      @current_date = @current_id[date] ||= []
    end
  end

  def valid_line?(line)
    line.match(REG_ID)
  end

  def str_to_date(string)
    Date.strptime(string, "%Y%m%d").to_s rescue nil
  end
end