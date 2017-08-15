class Rdm::Utils::FileUtils
  class << self
    def change_file(original_file, &block)
      return unless block_given?

      file_name = File.basename(original_file)
      tmp_file  = "/tmp/#{file_name}"

      File.open(tmp_file, 'w') do |file|
        File.foreach(original_file) do |line|
          new_value = yield line || line
          file.puts new_value
        end 
      end 

      FileUtils.cp(tmp_file, original_file)
      FileUtils.rm(tmp_file)
    end

    def relative_path(path:, from:)
      Pathname.new(path).relative_path_from(Pathname.new(from)).to_s
    end
  end
end