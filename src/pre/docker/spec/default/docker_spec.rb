require 'spec_helper'

describe package('docker-ce') do
  it { should be_installed }
end

describe package('docker-ce-cli') do
  it { should be_installed }
end

describe package('containerd.io') do
  it { should be_installed }
end

describe package('docker-compose-plugin') do
  it { should be_installed }
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe command('docker compose version') do
  its(:exit_status) { should eq 0 }
end
