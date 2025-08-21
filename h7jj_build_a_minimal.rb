require 'optparse'
require 'erb'

class MinimalCLI
  attr_reader :name, :description, :options, :templates

  def initialize(name, description)
    @name = name
    @description = description
    @options = {}
    @templates = {
      cli_file: erb_template('cli_file.erb'),
      readme_file: erb_template('readme_file.erb')
    }
  end

  def add_option(name, description, type)
    @options[name] = { description: description, type: type }
  end

  def generate
    dir_name = @name.downcase.gsub(/\s+/, '_')
    Dir.mkdir(dir_name) unless Dir.exist?(dir_name)

    cli_file_content = @templates[:cli_file].result(binding)
    File.write("#{dir_name}/#{dir_name}", cli_file_content)

    readme_file_content = @templates[:readme_file].result(binding)
    File.write("#{dir_name}/README.md", readme_file_content)
  end

  private

  def erb_template(filename)
    ERB.new(File.read("#{File.dirname(__FILE__)}/templates/#{filename}")).tap do |erb|
      erb.filename = filename
    end
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: ruby h7jj_build_a_minimal.rb [options]'

    opts.on('-n', '--name NAME', 'CLI tool name') do |v|
      options[:name] = v
    end

    opts.on('-d', '--description DESCRIPTION', 'CLI tool description') do |v|
      options[:description] = v
    end

    opts.on('-o', '--option NAME:TYPE:DESCRIPTION', 'Add option (e.g. -o foo:string:Foo description)') do |v|
      name, type, description = v.split(':')
      cli = MinimalCLI.new(options[:name], options[:description])
      cli.add_option(name, description, type)
      cli.generate
    end
  end.parse!
end