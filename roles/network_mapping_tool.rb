name "network_mapping_tool"
description "Installs the network mapping tool"
run_list ["recipe[network_mapping_tool]"]
override_attributes(
  java: {
    jdk_version: '7'
  },
  maven: {
    version: '2'
  },
  tomcat: {
    base_version: 7
  }
)
