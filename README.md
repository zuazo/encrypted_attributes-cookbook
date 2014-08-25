Description
===========
[![Cookbook Version](https://img.shields.io/cookbook/v/encrypted_attributes.svg?style=flat)](https://supermarket.getchef.com/cookbooks/encrypted_attributes)
[![Build Status](http://img.shields.io/travis/onddo/encrypted_attributes-cookbook.svg?style=flat)](https://travis-ci.org/onddo/encrypted_attributes-cookbook)

Installs and enables [chef-encrypted-attributes](http://onddo.github.io/chef-encrypted-attributes/) gem: Chef plugin to add Node encrypted attributes support using client keys.

Requirements
============

## Required Cookbooks

* [build-essential](https://supermarket.getchef.com/cookbooks/build-essential)

## Required Applications

* Ruby `1.9.3` or higher.

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
    <td>chef-encrypted-attributes mirror to download the gem from. For cases where you do not want to use RubyGems.</td>
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
  <tr>
    <td><code>node["dev_mode"]</code></td>
    <td>If this is <code>true</code>, the <code>Chef::EncryptedAttributesHelpers</code> library will work with clear attributes instead of encrypted attributes.</td>
    <td><em>calculated</em></td>
  </tr>
</table>

Recipes
=======

## encrypted_attributes::default

Installs and loads the `chef-encrypted-attributes` gem.

## encrypted_attributes::users_data_bag

Configures `chef-encrypted-attributes` Chef User keys reading them from a data bag. This is a workaround for the [Chef Users Limitation problem](http://onddo.github.io/chef-encrypted-attributes/#chef-users-limitation).

Helper Libraries
================

## Chef::EncryptedAttributesHelpers

This library adds some helper methods to try to cover the more common use cases.

Automatically includes the required recipes (`encrypted_attributes`) and gems (`chef-encrypted-attributes`), so you do not have to worry about them.

Also tries to simulate encrypted attributes creation (using clear attributes instead) in some testing environments:

* With *Chef Solo*.
* When `node["dev_mode"]` is set to `true`.

You must explicitly include the library before using it from recipes or resources:

```ruby
self.class.send(:include, Chef::EncryptedAttributesHelpers)
```

These are the available methods:

### encrypted_attributes_enabled?

Whether encrypted attributes are enabled underneath.

### encrypted_attribute_read(attr_ary)

Reads an encrypted attribute.

Parameters:

* `attr_ary`: attribute path as array. For example: `["ftp", "password"]`.

Returns the attribute value in clear text.

### encrypted_attribute_read_from_node(node, attr_ary)

Reads an encrypted attribute from a remote node.

Parameters:

* `node`: Node name.
* `attr_ary`: attribute path as array. For example: `["ftp", "password"]`.

Returns the attribute value in clear text.

### encrypted_attribute_write(attr_ary) {}

Creates and writes an encrypted attribute.

The attribute will be written only on first run and updated on the next runs. Because of this, the attribute value has to be set as a block, and the block will be run only the first time:

```ruby
clear_pass = encrypted_attribute_write(["ftp", "password"]) do
  self.class.send(:include, Opscode::OpenSSL::Password)
  secure_password
end
```

Parameters:

* `attr_ary`: attribute path as array. For example: `["ftp", "password"]`.

Returns the attribute value in clear text, that is, the value returned by the block.

### encrypted_attributes_allow_clients(search)

Allows some *Chef Clients* to read my encrypted attributes.

Parameters:

* `search`: Search query for clients that will be allowed to decrypt the attributes. For example `admin:true`.

### encrypted_attributes_allow_nodes(search)

Allows some *Chef Nodes* to read my encrypted attributes.

Parameters:

* `search`: Search query for nodes that will be allowed to decrypt the attributes. For example `role:webapp`.

### encrypted_attributes_enabled

This class attribute allows you to explicitly enable or disable encrypted attributes. This attribute value is *calculated* by default.

### Chef::EncryptedAttributesHelpers Example

Here a simple example to save a password encrypted:

```ruby
self.class.send(:include, Chef::EncryptedAttributesHelpers)

# Allow all webapp nodes and admin clients to read the attributes encrypted by me
encrypted_attributes_allow_clients("admin:true")
encrypted_attributes_allow_nodes("role:webapp")

ftp_pass = encrypted_attribute_write(["myapp", "ftp_password"]) do
  self.class.send(:include, Opscode::OpenSSL::Password)
  secure_password
end
```

You can then read the attribute as follows:

```ruby
ftp_pass = encrypted_attribute_read(["myapp", "ftp_password"])
```

Or read it from a remote node:

```ruby
self.class.send(:include, Chef::EncryptedAttributesHelpers)

ftp_pass = encrypted_attribute_read_from_node("myapp.example.com", ["myapp", "ftp_password"])
```

Don't forget to include the `encrypted_attributes` cookbook as a dependency in the metadata.

```ruby
# metadata.rb
[...]

depends "encrypted_attributes"
```

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

Another alternative is to include the default recipe in your *Run List*:

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

You can also use the `Chef::EncryptedAttributesHelpers` helpers to simplify its use:

```ruby
self.class.send(:include, Chef::EncryptedAttributesHelpers)

ftp_pass = encrypted_attribute_write(["myapp", "ftp_password"]) do
  self.class.send(:include, Opscode::OpenSSL::Password)
  secure_password
end
```

**Note:** This example requires the [openssl](https://supermarket.getchef.com/cookbooks/openssl) cookbook.

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

You can retrieve user public keys with `knife user show USER -a public_key -f json`.

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

**Note:** This data bag does not need to be encrypted, because it only stores public keys.

Testing
=======

See [TESTING.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/onddo/encrypted_attributes-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/TODO.md).


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
