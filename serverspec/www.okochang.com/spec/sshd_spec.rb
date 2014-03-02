require 'spec_helper'

describe package ('openssh-server') do
  it { should be_installed }
end

describe service('sshd') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('22222') do
  it { should be_listening }
end

describe file('/etc/ssh/sshd_config') do
  it { should be_file }
  it { should contain "PermitRootLogin forced-commands-only" }
  it { should contain "PasswordAuthentication no" }
end

