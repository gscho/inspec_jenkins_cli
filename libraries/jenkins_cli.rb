require 'mixlib/shellout'
require 'english'

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
    jar_path = options[:jar_path] || '/tmp/kitchen/cache/jenkins-cli.jar'
    @jar = inspec.file(jar_path)
    return skip_resource "Can't find cli \"#{@jar_path}\"" unless @jar.file?
    @source = options[:source] || 'http://localhost'
    @port = options[:port] || 8080
    @credentials = "--username #{options[:username]}" if options[:username]
    @credentials += " --password #{options[:password]}" if options[:password]
    @cli = "#{@java_home} -jar #{jar_path} -s #{@source}:#{@port}"
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
