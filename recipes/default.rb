# install pre-requisite packages
# => apt-get install maven        // should include all required java stuff.... I think

# run pre-requisite recipes (tomcat is probably actually here)
include_recipe "maven"    # may need to install openjdk-7 to get deps

# run postgresql recipe and create database

# run tomcat recipe

# checkout network mapping tool git repo
directory node[:network_mapping_tool][:source_directory] do
  owner node[:network_mapping_tool][:user]
  group node[:network_mapping_tool][:group]
  action :create
end
# => may need to generate a deploy key
git node[:network_mapping_tool][:source_directory] do
  repository node[:network_mapping_tool][:git][:repository]
  reference node[:network_mapping_tool][:git][:revision]
  action :sync
end

# ok, now build with maven
directory node[:network_mapping_tool][:deploy_directory] do
  owner node[:network_mapping_tool][:user]
  group node[:network_mapping_tool][:group]
  action :create
end
# => mvn deploy     // will download all dependancies and build WAR file