network_mapping_tool
====================

This is the cookbook to deploy Cybera's network mapping tool. (https://github.com/cybera/network-mapping-tool)

## Update knife.rb
Append these to your knife.rb file to make managing vaults easier
```
knife[:vault_mode] = 'client'
knife[:vault_admins] = [ 'chef-user1', 'chef-user2', 'chef-user3' ]
```

## Creating chef role
`knife role from file roles/network_mapping_tool.rb`

## Creating data vault for git deployment key
Since there cannot be any new line characters in the ssh key for the data bag, we need to remove them (deploy_key is the ssh private key used to access private git repo):

`ruby -rjson -e 'puts JSON.generate({"network_mapping_tool" => File.read("deploy_key")})' > vault-ssh-private.json`

Create the vault with the json file we just made:

`knife vault create deployment_keys network_mapping_tool vault-ssh-private.json -S "role:network_mapping_tool"`

## Bootstrap instance

```knife bootstrap 10.0.0.1 -x ubuntu -N netmap.hostname  --sudo -r "role[network_mapping_tool]" --bootstrap-vault-item deployment_keys:network_mapping_tool```
