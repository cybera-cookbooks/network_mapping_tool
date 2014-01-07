include_recipe "chef-client::service" if node[:chef_client][:run_as_daemon]
include_recipe "java"
include_recipe "tomcat"

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
# ----- start temp code -----
# right now we want to drop the database before anything else, so we need to make sure that its not being used, 
# so to do this we will stop tomcat
# perhaps an attribute that determines whether the database should be dropped each run would be a good thing
# something like if node[:network_mapping_tool][:development_mode]
execute "stop tomcat" do
  command "service tomcat7 stop"
end
postgresql_database node[:network_mapping_tool][:postgresql][:database_name] do
  owner node[:network_mapping_tool][:postgresql][:username]
  connection postgresql_connection_info
  action [:drop, :create]
  notifies :start, "service[tomcat]"
end
# ---- end temp code ----
package "postgresql-9.1-postgis"

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
  notifies :run, "execute[build_netmap]"
end

