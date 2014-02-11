maintainer       'Cybera'
maintainer_email 'devops@cybera.ca'
license          'All rights reserved'
name             'network_mapping_tool'
description      'Installs/Configures the Network Mapping Tool'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.0'

depends "database"
depends "maven"
depends "postgresql"
depends "postgis"
depends "ssh_known_hosts"
depends "tomcat"

recipe "default",         ""
