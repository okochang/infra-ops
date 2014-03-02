describe file('/swapfile') do
  it { should be_file }
end

describe file('/proc/swaps') do
  it { should contain '/swapfile' }
end
