require 'spec_helper'

describe file('/etc/localtime') do
  it { should be_linked_to '/usr/share/zoneinfo/Asia/Tokyo' }
end

describe command('date +"%Z"') do
  it { should return_stdout 'JST' }
end

