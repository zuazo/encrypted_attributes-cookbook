Description
===========
[![Cookbook Version](https://img.shields.io/cookbook/v/encrypted_attributes.svg)](https://community.opscode.com/cookbooks/encrypted_attributes)

Installs and enables [chef-encrypted-attributes](http://onddo.github.io/chef-encrypted-attributes/) gem: Chef plugin to add Node encrypted attributes support using client keys.

Requirements
============

No special requirements.

Attributes
==========

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>node["encrypted_attributes"]["version"]</code></td>
    <td>chef-encrypted-attributes gem version to install. The latest stable version is installed by default.</td>
    <td><em>calculated</em></td>
  </tr>
  <tr>
    <td><code>node["encrypted_attributes"]["mirror"]</code></td>
    <td>chef-encrypted-attributes mirror to download the gem from. For cases where you do not want to use rubygems.</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td><code>node["encrypted_attributes"]["data_bag"]["name"]</code></td>
    <td>chef-encrypted-attributes user keys data bag item name.</td>
    <td><code>"global"</code></td>
  </tr>
  <tr>
    <td><code>node["encrypted_attributes"]["data_bag"]["item"]</code></td>
    <td>chef-encrypted-attributes user keys data bag item name.</td>
    <td><code>"chef_users"</code></td>
  </tr>
</table>

Recipes
=======

### encrypted_attributes::default

Installs and loads the chef-encrypted-attributes gem.

### encrypted_attributes::users_data_bag

Configures chef-encrypted-attributes Chef User keys reading them from a data bag. This is a workaround for the [Chef Users Limitation problem](http://onddo.github.io/chef-encrypted-attributes/#chef-users-limitation).

Usage Examples
==============

## Including in a Cookbook Recipe

You can simply include it in a recipe:

```ruby
include_recipe "encrypted_attributes"
```

Don't forget to include the `encrypted_attributes` cookbook as a dependency in the metadata.

```ruby
# metadata.rb
[...]

depends "encrypted_attributes"
```

## Including in the Run List

Another alternative is to include the default recipe in your Run List:

```json
{
  "name": "ftp.onddo.com",
  [...]
  "run_list": [
    [...]
    "recipe[encrypted_attributes]"
  ]
}
```

## *encrypted_attributes::default* Recipe Usage Example

```ruby
include_recipe "encrypted_attributes"

Chef::Recipe.send(:include, Opscode::OpenSSL::Password) # include the #secure_password method

if Chef::EncryptedAttribute.exists?(node["myapp"]["ftp_password"])
  # update with the new keys
  Chef::EncryptedAttribute.update(node.set["myapp"]["ftp_password"])

  # read the password
  ftp_pass = Chef::EncryptedAttribute.load(node["myapp"]["ftp_password"])
else
  # create the password and save it
  ftp_pass = secure_password
  node.set["myapp"]["ftp_password"] = Chef::EncryptedAttribute.create(ftp_pass)
end

# use `ftp_pass` for something here ...
```

**Note:** This example requires the [openssl](http://community.opscode.com/cookbooks/openssl) cookbook.

See the [`chef-encrypted-attributes` gem Usage](http://onddo.github.io/chef-encrypted-attributes/#usage-in-recipes) section for more examples.

## *encrypted_attributes::users_data_bag* Recipe Usage Example

Before using this recipe, you must create the required data bag:

    $ knife data bag create global_data chef_users

You should create a data bag item with the following format:

```json
{
  "id": "chef_users",
  "bob": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFA...",
  "alice": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFA..."
}
```

The keys can be set in *array of strings* format if you prefer:

```json
{
  "id": "chef_users",
  "bob": [
    "-----BEGIN PUBLIC KEY-----",
    "MIIBIjANBgkqhkiG9w0BAQEFA...",
    ...
  ],
  "alice": [
    "-----BEGIN PUBLIC KEY-----",
    "MIIBIjANBgkqhkiG9w0BAQEFA...",
    ...
  ]
}
```

Then, you can use this data bag to configure the `Chef::Config[:encrypted_attributes][:keys]` chef-encrypted-attributes configuration only by calling the recipe:

```ruby
node.default["encrypted_attributes"]["data_bag"]["name"] = "global_data"
include_recipe "encrypted_attributes::users_data_bag"

# if Chef::EncryptedAttribute.exists_on_node?(...)
#   Chef::EncryptedAttribute.update(...)
# else
#   node.set[...][...] = Chef::EncryptedAttribute.create(...)
# ...
```

Testing
=======

## Requirements

* `vagrant`
* `berkshelf` >= `2.0.0`
* `test-kitchen` >= `1.2`
* `kitchen-vagrant` >= `0.10`

## Running the Tests

```bash
$ kitchen test
$ kitchen verify
[...]
```

### Running the tests in the cloud

#### Requirements:

* `kitchen-vagrant` >= `0.10`
* `kitchen-digitalocean` >= `0.5`
* `kitchen-ec2` >= `0.8`

You can run the tests in the cloud instead of using vagrant. First, you must set the following environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_KEYPAIR_NAME`: EC2 SSH public key name. This is the name used in Amazon EC2 Console's Key Pars section.
* `EC2_SSH_KEY_PATH`: EC2 SSH private key local full path. Only when you are not using an SSH Agent.
* `DIGITAL_OCEAN_CLIENT_ID`
* `DIGITAL_OCEAN_API_KEY`
* `DIGITAL_OCEAN_SSH_KEY_IDS`: DigitalOcean SSH numeric key IDs.
* `DIGITAL_OCEAN_SSH_KEY_PATH`: DigitalOcean SSH private key local full path. Only when you are not using an SSH Agent.

Then, you must configure test-kitchen to use `.kitchen.cloud.yml` configuration file:

```
$ export KITCHEN_LOCAL_YAML=".kitchen.cloud.yml"
$ kitchen list
[...]
```

Contributing
============

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Author
=====================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@onddo.com>)
| **Copyright:**       | Copyright (c) 2014, Onddo Labs, SL. (www.onddo.com)
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
