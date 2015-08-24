class FileParser
  ROOT = File.expand_path(File.dirname(__FILE__))

  def initialize(list)
    @list = Dir.glob(list)
  end

  def start
    @list.each do |file_path|
      File.open file_path, 'r' do |file|
        p file.read
      end
    end
  end
end