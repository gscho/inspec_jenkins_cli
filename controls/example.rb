# encoding: utf-8
# copyright: 2017, Greg Schofield

title 'jenkins_cli examples'

config = {}
config[:username] = 'test'
config[:password] = 'foo'

# check for the existance of the jenkins-cli.jar
describe jenkins_cli(config) do
  it { should exist }
end

# Control for checking for the existance of a jenkins plugin
control 'blueocean-plugin-1.0' do
  impact 1.0
  title 'Check for blueocean plugin'
  desc 'The blueocean plugin should be installed on the jenkins instance'
  describe jenkins_cli(config).plugins do
    its('stdout') { should match(/blueocean/) }
    its('exit_status') { should be 0 }
  end
end
