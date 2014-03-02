require 'spec_helper'

describe command('df -h / | awk 'NR==2 {print $2}'') do
  it { should return_stdout '20G' }
end
