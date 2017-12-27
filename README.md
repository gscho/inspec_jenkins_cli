# Jenkins CLI InSpec Resource

This InSpec profile contains the jenkins_cli resource which can be used to test a running jenkins instance. The resource can be used to list plugins, jobs, credentials, etc. which can be useful when writing integration tests. Currently the resource has only been tested against SLES 12 but it should work with any 'nix based OS.

## Requirements

### Tested Platforms
- SLES 12
- TBD.

### Tested Inspec Version
- InSpec 1.48.0


## Resource

### jenkins_cli
The base resource. It can be used for checking for the existance for the jenkins-cli.jar file. It also accepts a hash with the following (optional) parameters:  
`java_home` - default is `'/usr/bin/java'`  
`jar_path` - default is `'/tmp/kitchen/cache/jenkins-cli.jar'`  
`source` - default is `'http://localhost'`  
`port` -  default is `8080`  
`username` - default is `nil`  
`password` - default is `nil`

Example:
```
config = {}
config['username'] = 'test'
config['password'] = 'foo'

# check for the existance of the jenkins-cli.jar
describe jenkins_cli(config) do
  it { should exist }
end
```

### jenkins_cli.plugins
Convenience function for listing all plugins installed on the jenkins instance.  
Example:
```
describe jenkins_cli(config).plugins do
  its('stdout') { should match(/my_plugin/) }
  its('exit_status') { should be 0 }
end
```
### jenkins_cli.jobs
Convenience function for listing all jobs configured on the jenkins instance.  
Example:
```
describe jenkins_cli(config).jobs do
  its('stdout') { should match(/my_job/) }
  its('exit_status') { should be 0 }
end
```
### jenkins_cli.exec
Convenience function for executing valid jenkins-cli commands.  
Example using `'get-job'` which will return the job's xml file:
```
xml = File.read('my_job_def.xml')
describe jenkins_cli(config).exec('get-job my_job') do
  its('stdout') { should eq xml }
  its('exit_status') { should be 0 }
end
```
