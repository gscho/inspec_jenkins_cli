require 'mixlib/shellout'
require 'english'
require 'fileutils'
require 'net/http'
require 'uri'

class JenkinsCLI < Inspec.resource(1)
  name 'jenkins_cli'

  desc '
    Check jenkins configuration using the jenkins CLI jar.
  '

  example '
    describe jenkins_cli do
      it { should exist }
    end
  '

  def initialize(options)
    @java_home = options[:java_home] || '/usr/bin/java'
    @jar_path = options[:jar_path] || '/tmp/kitchen/cache/jenkins-cli.jar'
    @source = options[:source] || 'http://localhost'
    @port = options[:port] || 8080
    @jar = do_download_cli(options)
    return skip_resource "Can't find cli \"#{@jar_path}\"" unless @jar.file?
    @credentials = "--username #{options[:username]}" if options[:username]
    @credentials += " --password #{options[:password]}" if options[:password]
    @cli = "#{@java_home} -jar #{@jar_path} -s #{@source}:#{@port}"
  end

  def do_download_cli(opts)
    cli = inspec.file(@jar_path)
    if cli.file?
      return cli
    else
      uri = URI.parse("#{@source}:#{@port}/jnlpJars/jenkins-cli.jar")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(opts[:username], opts[:password])
      FileUtils.mkdir_p(File.dirname(@jar_path))
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request) do |resp|
          open(@jar_path, "wb") do |f|
            f.write(resp.body)
          end
        end
      end
      return inspec.file(@jar_path)
    end
  end

  def plugins
    exec('list-plugins')
    self
  end

  def jobs
    exec('list-jobs')
    self
  end

  def exec(cli_func)
    @command = "#{@cli} #{cli_func}"
    @command = "#{@command} #{@credentials}" if @credentials
    begin
      @res = inspec.command(@command)
    rescue StandardError
      return skip_resource "Command #{@command} failed in error: #{$ERROR_INFO}"
    end
  end

  def stdout
    @res.stdout
  end

  def stderr
    @res.stderr
  end

  def exit_status
    @res.exit_status.to_i
  end

  def exists?
    @jar.file?
  end

  def method_missing(name)
    @params[name.to_s]
  end
end
