module FileParser
	def self.process_files(files)
		files = files.empty? ? Dir.glob("**/*.txt") : files
		file_contents = []

		files.each do |file|
			file_contents << [File.readlines(file), file]
		end

		file_contents
	end
end