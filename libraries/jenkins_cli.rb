require 'mixlib/shellout'

class JenkinsCLI < Inspec.resource(1)
    name 'jenkins_cli'
   
    desc '
      Check jenkins configuration using the jenkins CLI jar.
    '
   
    example '
      describe jenkins_cli('dummy_service_6') do
        its('port') { should eq('6382') }
        its('slave-priority') { should eq('69') }
      end
    '
   
    def initialize(options)
      @params = {}
      @command = options['cmd']
      @port = options['port'] || 8080
      @username = options['username']
      @password = options['password']
      cmd = Mixlib::ShellOut.new(@command)
      begin
        cmd.run_command
        @params['content'] = cmd.stdout
      rescue Exception
        return skip_resource "#{@file}: #{$!}"
      end
    end
   
    def exists?
      @file.file?
    end
   
    def method_missing(name)
      @params[name.to_s]
    end
   
  end