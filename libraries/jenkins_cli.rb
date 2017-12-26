require 'mixlib/shellout'

class JenkinsCLI < Inspec.resource(1)
    name 'jenkins_cli'
   
    desc '
      Check jenkins configuration using the jenkins CLI jar.
    '
   
    example "
      describe jenkins_cli('dummy_service_6') do
        its('port') { should eq('6382') }
        its('slave-priority') { should eq('69') }
      end
    "
   
    def initialize(options)
      @java_home = options['java_home'] || '/usr/bin/java'
      jar_path = options['jar_path'] || '/tmp/kitchen/cache/jenkins-cli.jar'
      @jar = inspec.file(tmp)
      @source = options['source'] || 'localhost' 
      @port = options['port'] || 8080
      @username = options['username']
      @password = options['password']
      @cli = "#{@java_home} #{@jar_path} -s #{@source}:#{@port}"
      @credentials = "--username #{@username} --password #{@password}" if @username
      return skip_resource "Can't find cli \"#{@jar_path}\"" if !@jar.file?
    end
   
    def plugins
      exec('list-plugins')
    end
   
    def exec(command)
      @params = {}
      begin
        cmd = "#{@cli} #{command}"
        cmd = "#{tmp} #{@credentials}" if @credentials
        res = inspec.command(cmd)
        @params['stdout'] = res.stdout
        @params['stderr'] = res.stderr
        @params['exit_status'] = res.exit_status
      rescue Exception
        return skip_resource "Command #{cmd} failed in error: #{$!}"
      end
    end

    def exists?
      @jar.file?
    end  

    def method_missing(name)
      @params[name.to_s]
    end
   
  end