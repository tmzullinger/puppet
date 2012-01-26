module PuppetSpec::Modules
  def self.create(name, modulepath, options = {})
    dependable_dir = File.join(modulepath, name)
    Dir.mkdir(dependable_dir)
    unless options[:nometadata]
      metadata = File.join(dependable_dir, 'metadata.json')

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
  end
end
