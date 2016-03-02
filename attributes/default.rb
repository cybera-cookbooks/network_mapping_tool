default[:network_mapping_tool][:source_directory] = "/opt/network_mapping_tool/src"
default[:network_mapping_tool][:user] = "www-data"
default[:network_mapping_tool][:group] = "www-data"
default[:network_mapping_tool][:admin][:password] = "supersecret"

default[:network_mapping_tool][:git][:repository] = "https://github.com/cybera/network-mapping-tool"
default[:network_mapping_tool][:git][:revision] = "master"

default[:network_mapping_tool][:postgresql][:database_name] = "netmap"
default[:network_mapping_tool][:postgresql][:username] = 'cybera'
default[:network_mapping_tool][:postgresql][:password] = 'cybera.123'

default[:postgresql][:password][:postgres] = "supersecret"
default['postgresql']['version'] = "9.3"

default[:tomcat][:port] = 8080
# override[:tomcat][:webapp_dir] = default[:network_mapping_tool][:deploy_directory]
default[:tomcat][:keytool] = "/usr/bin/keytool"

default[:cmdb][:api][:internal_url] = "https://netmap.cybera.ca"
default[:cmdb][:api][:external_url] = "https://netmap.cybera.ca"

# Maven 2.X is EOL, so we need to use the archive
default["maven"]["2"]["url"] = "http://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz"
