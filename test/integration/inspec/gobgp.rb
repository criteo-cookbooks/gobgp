bgp_expected_local_as = 64_501
bgp_expected_port = 1790
lan_ip = command('hostname -i').stdout.strip

describe port(bgp_expected_port) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
end

describe command('/usr/local/bin/gobgp global') do
  its('stdout') { should match(/AS: +#{bgp_expected_local_as}/) }
  its('stdout') { should match(/Router-ID: +#{lan_ip}/) }
end
