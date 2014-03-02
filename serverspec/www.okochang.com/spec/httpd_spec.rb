require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('80') do
  it { should be_listening }
end

describe file('/etc/httpd/conf/httpd.conf') do
  it { should be_file }
  it { should contain "ServerTokens ProductOnly" }
  it { should contain "HostnameLookups Off" }
  it { should contain "ServerSignature Off" }
end

describe file('/etc/httpd/conf.d/vhosts.conf') do
  it { should be_file }
  it { should contain "ServerName www.okochang.com" }
end
