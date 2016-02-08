include_recipe 'apt'

["make", "language-pack-en"].each do |pkg|
  package pkg do
  end.run_action(:install)
end

# Chef Vault for GitHub deployment key
chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end
require 'chef-vault'
netmap_vault = ChefVault::Item.load("deployment_keys", "network_mapping_tool")


# run postgresql recipe and create database
include_recipe "postgresql::server"
include_recipe "database::postgresql"
include_recipe 'postgis::default'

postgresql_connection_info = {
  :host     => 'localhost',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}
postgresql_database_user node[:network_mapping_tool][:postgresql][:username] do
  password node[:network_mapping_tool][:postgresql][:password]
  connection postgresql_connection_info
  action :create
end
postgresql_database node[:network_mapping_tool][:postgresql][:database_name] do
  owner node[:network_mapping_tool][:postgresql][:username]
  template node[:postgis][:template_name]
  connection postgresql_connection_info
  action :create
end

include_recipe "java"
include_recipe "tomcat"
include_recipe "maven"
execute "build_netmap" do
  cwd "#{node[:network_mapping_tool][:source_directory]}/netmap/"
  command "mvn clean && mvn package && cp target/*.war #{node[:tomcat][:webapp_dir]}/ROOT.war && rm -rf #{node[:tomcat][:webapp_dir]}/ROOT "
  action :nothing
end

# checkout network mapping tool git repo
directory node[:network_mapping_tool][:source_directory] do
  owner node[:network_mapping_tool][:user]
  group node[:network_mapping_tool][:group]
  recursive true
  action :create
end
directory "#{node[:etc][:passwd][:root][:dir]}/.ssh" do
  recursive true
  action :create
end
file "#{node[:etc][:passwd][:root][:dir]}/.ssh/id_rsa" do
  content netmap_vault["ssh_deployment_key"]
  owner "root"
  mode 0600
end
ssh_known_hosts_entry 'github.com'
package "git"
git node[:network_mapping_tool][:source_directory] do
  repository node[:network_mapping_tool][:git][:repository]
  reference node[:network_mapping_tool][:git][:revision]
  action :sync
  notifies :run, "execute[build_netmap]"
end

Chef::Log.error "------\n#{node[:cmdb][:api][:internal_url]}"
template "#{node[:network_mapping_tool][:source_directory]}/netmap/src/main/resources/netmap.properties" do
  source "netmap.properties.erb"
  mode 0644
  notifies :run, "execute[build_netmap]"
end

template "#{node[:network_mapping_tool][:source_directory]}/netmap/src/main/webapp/WEB-INF/spring/root-context.xml" do
  source "root-context.xml.erb"
  mode 0644
  variables(
    db_user: node[:network_mapping_tool][:postgresql][:username],
    db_password: node[:network_mapping_tool][:postgresql][:password]
  )
  notifies :run, "execute[build_netmap]"
end  

cron "run-chef-solo" do
  minute "*/5"
  user "root"
  command "chef-solo -c /home/ubuntu/chef-solo/solo.rb -j /home/ubuntu/chef-solo/dna.json"
end
