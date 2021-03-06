require 'date'

class FileParser
  TYPES = %w[account activity position security]
  YEAR_RANGE = 1900..(Date.today.year + 50)

  REG_ID   = /U[0-9]+/
  REG_DATE = /,([0-9]{8}),/
  REG_TYPES = Regexp.new TYPES.map(&:capitalize).join('|')

  def initialize(list)
    @list = Dir.glob(list)
    @result = {}
    @output = ''
  end

  def start
    @list.each do |file_path|
      File.open(file_path, 'r') do |file|
         file.read.split(/\n/).each do |line|
          @line = line
          start_chain if valid_line? line
        end
        file.close
      end
    end

    print result
  end

  def result
    draw(list: @result, level: :id) do |date_sublist|
      draw(list: date_sublist, level: :date) do |type_sublist|
        draw(list: type_sublist, level: :type)
      end
    end

    @output
  end

  private
  def start_chain
    find_or_create_id
  end

  def find_or_create_id
    match = @line.match(REG_ID)[0]
    @current_id = @result[match] ||= {} 

    find_or_create_date
  end

  def find_or_create_date
    @line.scan(REG_DATE) do |date_string|
      date = str_to_date(date_string)
      next unless date
      @current_date = @current_id[date] ||= []

      find_or_create_type
    end
  end

  def find_or_create_type
    @line.scan(REG_TYPES) do |type_string|
      unless @current_date.include? type_string
        @current_date << type_string
      end
    end
  end

  def draw(args)
    # args[:list] == [%key%, %value%]

    args[:list].sort.each do |sublist|
      unless sublist.kind_of? String
        add_line(level: args[:level], value: sublist[0])
        yield(sublist[1]) if block_given?
      else
        add_line(level: args[:level], value: sublist.downcase)
      end
    end
  end

  def add_line(args)
    tab = 
      case args[:level]
      when :id   then ''    
      when :date then ' '
      when :type then ' ' * 2
      end

    @output << tab << args[:value] << "\n"
  end

  def valid_line?(line)
    line.match(REG_ID)
  end

  def str_to_date(string)
    begin
      string = string.first.gsub(/,/, '')
      date = Date.strptime(string, "%Y%m%d")
   
      raise unless YEAR_RANGE.include? date.year
      
      date.to_s
    rescue 
      nil
    end
  end
end