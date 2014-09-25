require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'logstash::pattern' do

  let(:title) { 'my_pattern' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :logstash_version => '1.4.2' } }

  let(:params) {
    { 'ensure'       =>  'present',
      'source'       =>  'puppet:///logstash/pattern/example42.conf',
    }
  }

  describe 'Test logstash::pattern populated with source file' do
    it 'should create a logstash::pattern file' do
      should contain_file('logstash_pattern.conf_my_pattern').with_ensure('present')
    end
    it 'should populate correctly logstash::pattern file with a given source' do
      should contain_file('logstash_pattern.conf_my_pattern').with_source('puppet:///logstash/pattern/example42.conf')
    end
    it { should contain_file('logstash_pattern.conf_my_pattern').with_path('/etc/logstash/patterns/my_pattern.conf') }
  end

end

