node.override['apt']['compile_time_update'] = true
include_recipe "apt"

node.override['build-essential']['compile_time'] = true
include_recipe "build-essential"

["make", "language-pack-en"].each do |pkg|
  package pkg do
  end.run_action(:install)
end

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
