require 'mixlib/shellout'

class JenkinsCLI < Inspec.resource(1)
    name 'jenkins_cli'
   
    desc '
      Check jenkins configuration using the jenkins CLI jar.
    '
   
    example '
      config = {}
      config['cmd']
      describe jenkins_cli('dummy_service_6') do
        its('port') { should eq('6382') }
        its('slave-priority') { should eq('69') }
      end
    '
   
    def initialize(options)
      @java_home = options['java_home'] || '/usr/bin/java'
      @jar_path = options['jar_path'] || '/tmp/kitchen/cache/jenkins-cli.jar'
      @source = options['source'] || 'localhost' 
      @port = options['port'] || 8080
      @username = options['username']
      @password = options['password']
      @cli = "#{java_home} #{jar_path} -s #{source}:#{port}" 
    end
   
    def plugins
      @params = {}
      cmd = Mixlib::ShellOut.new(@cli)
      begin
        cmd.run_command
        @params['plugins'] = cmd.stdout
      rescue Exception
        return skip_resource "#{@file}: #{$!}"
      end
    end
   
    def method_missing(name)
      @params[name.to_s]
    end
   
  end