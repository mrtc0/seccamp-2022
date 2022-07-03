execute "apt-get update" do
  command "apt-get update"
end

%w(
  wget
  curl
  build-essential
  libbpf-dev
  clang
  gcc-multilib
  llvm
  zlib1g-dev
  libelf-dev
  linux-tools-generic
  linux-tools-common
  ca-certificates
  gnupg
  lsb-release
).each do |package_name|
  package package_name
end

include_recipe "./docker.rb"
