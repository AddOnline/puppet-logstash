require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'logstash' do

  let(:title) { 'logstash' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }

  describe 'Test standard installation via package' do
    let(:params) { {:install => 'package' } }

    it { should contain_package('logstash').with_ensure('present') }
  end

  describe 'Test installation via netinstall' do
    let(:params) { {:version => '1.1.1' } }
    it 'should install version 1.1.1 via netinstall' do
      should contain_puppi__netinstall('netinstall_logstash').with_url(/http:\/\/logstash.objects.dreamhost.com\/release\/logstash-1.1.1-flatjar.jar/)
    end
    it { should contain_puppi__netinstall('netinstall_logstash').with_extract_command('cp ') }
    it { should contain_file('logstash_link').with_ensure('/opt/logstash/logstash-1.1.1-flatjar.jar') }
    it { should contain_file('logstash_link').with_path('/opt/logstash/logstash.jar') }
  end

  describe 'Test installation via puppi' do
    let(:params) { {:version => '1.1.1' , :install => 'puppi' } }
    it 'should install version 1.1.1 via puppi' do
      should contain_puppi__project__war('logstash').with_source(/http:\/\/logstash.objects.dreamhost.com\/release\/logstash-1.1.1-flatjar.jar/)

    end
  end

  describe 'Test package installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :install => 'package' , :firewall => true, :port => '42', :protocol => 'tcp' } }

    it { should contain_package('logstash').with_ensure('present') }
    it 'should monitor the process' do
      should contain_monitor__process('logstash_process').with_enable(true)
    end
    it 'should place a firewall rule' do
      should contain_firewall('logstash_tcp_42').with_enable(true)
    end
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it 'should remove Package[logstash]' do should contain_package('logstash').with_ensure('absent') end
    it 'should not enable at boot Service[logstash]' do should contain_service('logstash').with_enable('false') end
    it 'should not monitor the process' do
      should contain_monitor__process('logstash_process').with_enable(false)
    end
    it 'should remove a firewall rule' do
      should contain_firewall('logstash_tcp_42').with_enable(false)
    end
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it { should contain_package('logstash').with_ensure('present') }
    it 'should not monitor the process' do
      should contain_monitor__process('logstash_process').with_enable(false)
    end
    it 'should remove a firewall rule' do
      should contain_firewall('logstash_tcp_42').with_enable(false)
    end
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it { should contain_package('logstash').with_ensure('present') }
    it 'should not enable at boot Service[logstash]' do should contain_service('logstash').with_enable('false') end
    it 'should not monitor the process locally' do
      should contain_monitor__process('logstash_process').with_enable(false)
    end
    it 'should keep a firewall rule' do
      should contain_firewall('logstash_tcp_42').with_enable(true)
    end
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "logstash/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      should contain_file('logstash.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('logstash.conf').with_content(/value_a/)
    end

  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/logstash/spec" , :source_dir => "puppet://modules/logstash/dir/spec" , :source_dir_purge => true } }

    it 'should request a valid source ' do
      should contain_file('logstash.conf').with_source("puppet://modules/logstash/spec")
    end
    it 'should request a valid source dir' do
      should contain_file('logstash.dir').with_source("puppet://modules/logstash/dir/spec")
    end
    it 'should purge source dir if source_dir_purge is true' do
      should contain_file('logstash.dir').with_purge(true)
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "logstash::spec" , :template => "logstash/spec.erb"} }
    it 'should automatically include a custom class' do
      should contain_file('logstash.conf').with_content(/fqdn: rspec.example42.com/)
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it 'should generate a puppi::ze define' do
      should contain_puppi__ze('logstash').with_helper("myhelper")
    end
  end

  describe 'Test Monitoring Tools Integration' do
    let(:params) { {:monitor => true, :monitor_tool => "puppi" } }

    it 'should generate monitor defines' do
      should contain_monitor__process('logstash_process').with_tool("puppi")
    end
  end

  describe 'Test Firewall Tools Integration' do
    let(:params) { {:firewall => true, :firewall_tool => "iptables" , :protocol => "tcp" , :port => "42" } }

    it 'should generate correct firewall define' do
      should contain_firewall('logstash_tcp_42').with_tool("iptables")
    end
  end

  describe 'Test OldGen Module Set Integration' do
    let(:params) { {:monitor => "yes" , :monitor_tool => "puppi" , :firewall => "yes" , :firewall_tool => "iptables" , :puppi => "yes" , :port => "42" , :protocol => 'tcp' } }

    it 'should generate monitor resources' do
      should contain_monitor__process('logstash_process').with_tool("puppi")
    end
    it 'should generate firewall resources' do
      should contain_firewall('logstash_tcp_42').with_tool("iptables")
    end
    it 'should generate puppi resources ' do
      should contain_puppi__ze('logstash').with_ensure("present")
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour top scope global vars' do
      should contain_monitor__process('logstash_process').with_enable(true)
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :logstash_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour module specific vars' do
      should contain_monitor__process('logstash_process').with_enable(true)
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :logstash_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour top scope module specific over global vars' do
      should contain_monitor__process('logstash_process').with_enable(true)
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :monitor => true , :firewall => true, :port => '42' } }

    it 'should honour passed params over global vars' do
      should contain_monitor__process('logstash_process').with_enable(true)
    end
  end

  describe 'Test init service script creation' do
    let(:params) { {:version => '1.1.1' } }
    it { should contain_file('logstash.init').with_ensure('present') }
    it { should contain_file('logstash.init').with_path('/etc/init.d/logstash') }
    it { should contain_file('logstash.init').with_mode('0755') }
    it { should contain_file('logstash.init').with_owner('root') }
    it { should contain_file('logstash.init').with_group('root') }
    it { should contain_file('logstash.init').with_content(/java -jar \/opt\/logstash\/logstash-1.1.1-flatjar.jar/) }
  end

  describe 'Test init service script creation with logstash > 1.4.0' do
    let(:params) { {:version => '1.4.2' } }
    it { should contain_file('logstash.init').with_ensure('present') }
    it { should contain_file('logstash.init').with_path('/etc/init.d/logstash') }
    it { should contain_file('logstash.init').with_mode('0755') }
    it { should contain_file('logstash.init').with_owner('root') }
    it { should contain_file('logstash.init').with_group('root') }
    it { should contain_file('logstash.init').with_content(/DAEMON=\/opt\/logstash\/logstash\/bin\/logstash/) }
  end

  describe 'Test install logstash < 1.4.0' do
    let(:params) { {:version => '1.1.1' } }

    it { should contain_file('logstash.dir').with_path('/etc/logstash') }
  end

  describe 'Test install logstash > 1.4.0' do
    let(:params) { {:version => '1.4.2' } }

    it { should contain_puppi__netinstall('netinstall_logstash').with_url(/http:\/\/download\.elasticsearch\.org\/logstash\/logstash\/logstash-1\.4\.2\.tar\.gz/) }
    it { should contain_puppi__netinstall('netinstall_logstash').with_extract_command('') }
    it { should contain_file('logstash_link').with_ensure('/opt/logstash/logstash-1.4.2') }
    it { should contain_file('logstash_link').with_path('/opt/logstash/logstash') }

    it { should contain_file('logstash_var_lib').with_ensure('directory') }
    it { should contain_file('logstash_var_lib').with_path('/var/lib/logstash') }
    it { should contain_file('logstash_var_lib').with_owner('logstash') }
    it { should contain_file('logstash_var_lib').with_group('logstash') }

    it { should contain_file('logstash.dir').with_path('/etc/logstash/conf.d') }
  end
end
