default[:network_mapping_tool] = {
  deploy_directory: "/opt/network_mapping_tool/bin",
  source_directory: "/opt/network_mapping_tool/src",
  user: "www-data",
  group: "www-data",
  git: {
    repository: "git@github.com:cybera/network-mapping-tool.git",
    revision: "master"
  }
}
