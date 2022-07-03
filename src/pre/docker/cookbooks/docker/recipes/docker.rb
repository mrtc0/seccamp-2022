execute "install gpg key" do
  command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"

  not_if 'test -e /usr/share/keyrings/docker-archive-keyring.gpg'
end

execute "Add repository" do
  command 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null'

  not_if 'test -e /etc/apt/sources.list.d/docker.list'
end

execute "apt-get update" do
  command "apt-get update"
end

%w(docker-ce docker-ce-cli containerd.io docker-compose-plugin).each do |package_name|
  package package_name
end

