include_recipe "java"
# run postgresql recipe and create database
include_recipe "postgresql::server"
include_recipe "database::postgresql"
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
  connection postgresql_connection_info
  action :create
end
package "postgresql-9.1-postgis"

# checkout network mapping tool git repo
directory node[:network_mapping_tool][:source_directory] do
  owner node[:network_mapping_tool][:user]
  group node[:network_mapping_tool][:group]
  recursive true
  action :create
end
file "#{node[:etc][:passwd][:root][:dir]}/.ssh/id_rsa" do
  content node[:network_mapping_tool][:git][:deploy_key]
  owner "ubuntu"
  mode 0600
end
ssh_known_hosts_entry 'github.com'
package "git"
git node[:network_mapping_tool][:source_directory] do
  repository node[:network_mapping_tool][:git][:repository]
  reference node[:network_mapping_tool][:git][:revision]
  action :sync
end

# install and set up tomcat
include_recipe "tomcat"
include_recipe "maven"
execute "build_netmap" do
  cwd "#{node[:network_mapping_tool][:source_directory]}/netmap/"
  command "mvn clean && mvn package && cp target/*.war #{node[:tomcat][:webapp_dir]}/ROOT.war && rm -rf #{node[:tomcat][:webapp_dir]}/ROOT "
end