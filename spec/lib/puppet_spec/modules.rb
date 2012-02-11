module PuppetSpec::Modules
  class << self
    include PuppetSpec::Files
    def create(name, dir, options = {})
      module_dir = File.join(dir, name)
      Dir.mkdir(module_dir)
      unless options[:nometadata]
        metadata = File.join(module_dir, 'metadata.json')

        author       = (options[:author] || 'matt')
        version      = (options[:version] || '1.0.0').to_pson
        dependencies = (options[:dependencies] || []).to_pson

        File.open(metadata, 'w') do |file|
          file.puts <<-HEREDOC
            {
              "license":      "to kill",
              "dependencies": #{dependencies},
              "author":       #{author.to_pson},
              "name":         "#{author}/#{name}",
              "source":       "whocares",
              "version":      #{version}
            }
          HEREDOC
        end
      end
      module_dir
    end
  end
end
