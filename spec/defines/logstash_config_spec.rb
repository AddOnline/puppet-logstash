require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'logstash::config' do

  let(:title) { 'local_search' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :arch => 'i386' , :operatingsystem => 'redhat' } }

  let(:params) {
    { 'ensure'       =>  'present',
      'source'       =>  'puppet:///logstash/config/local_search.erb',
    }
  }

  describe 'Test logstash::config populated with source file' do
    it 'should create a logstash::config file' do
      should contain_file('logstash.conf_local_search').with_ensure('present')
    end
    it 'should populate correctly logstash::config file with a given source' do
      content = catalogue.resource('file', 'logstash.conf_local_search').send(:parameters)[:source]
      content.should match "puppet:///logstash/config/local_search"
    end
    it { should contain_file('logstash.conf_local_search').with_path('/etc/logstash/local_search.conf') }
  end

  describe 'Test logstash version > 1.4.0' do
    let(:facts) { { :logstash_version => '1.4.2' } }
    it { should contain_file('logstash.conf_local_search').with_path('/etc/logstash/conf.d/local_search.conf') }
  end

end

