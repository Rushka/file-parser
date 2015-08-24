class FileParser
  REG_ID = /U[0-9]+/

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
        if line.match(REG_ID)
          find_or_create_id line          
        end
      end
    end
  end

  private
  def find_or_create_id(line)
    match = line.match(REG_ID)[0]
    @result[match] ||= {} 
  end
end