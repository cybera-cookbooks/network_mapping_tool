network_mapping_tool
====================

This is the cookbook to deploy Cybera's network mapping tool. (https://github.com/cybera/network-mapping-tool)

## Creating chef role
`knife role from file roles/network_mapping_tool.rb`

## Bootstrap instance

```knife bootstrap 10.0.0.1 -x ubuntu -N netmap.hostname  --sudo -r "role[network_mapping_tool]"```
