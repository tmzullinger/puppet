module PuppetSpec::Modules
  class << self
    include PuppetSpec::Files
    def create(name, modulepath, options = {})
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

    def build_and_install(full_module_name, release_name, options = {})
      Puppet::Module::Tool::Applications::Generator.run(full_module_name)
      Puppet::Module::Tool::Applications::Builder.run(full_module_name)

      FileUtils.mv("#{full_module_name}/pkg/#{release_name}.tar.gz", "#{release_name}.tar.gz")
      FileUtils.rm_rf(full_module_name)

      Puppet::Module::Tool::Applications::Installer.run("#{release_name}.tar.gz", options)
    end

    # Return STDOUT and STDERR output generated from +block+ as it's run within a temporary test directory.
    def run(&block)
      mktestdircd do
        block.call
      end
    end

    # Return path to temparory directory for testing.
    def testdir
      return @testdir ||= tmpdir("module_tool_testdir")
    end

    # Create a temporary testing directory, change into it, and execute the
    # +block+. When the block exists, remove the test directory and change back
    # to the previous directory.
    def mktestdircd(&block)
      previousdir = Dir.pwd
      rmtestdir
      FileUtils.mkdir_p(testdir)
      Dir.chdir(testdir)
      block.call
    ensure
      rmtestdir
      Dir.chdir previousdir
    end

    # Remove the temporary test directory.
    def rmtestdir
      FileUtils.rm_rf(testdir) if File.directory?(testdir)
    end
    # END helper methods

  end
end
