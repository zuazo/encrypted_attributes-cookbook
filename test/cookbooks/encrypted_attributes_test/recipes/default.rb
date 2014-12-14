# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes_test
# Recipe:: default
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'encrypted_attributes'

orig_value = {
  'a_key' => 'Some random string',
  'primitives' => [0, 0.2, true, false, nil]
}

Chef::Log.info("Attribute decrypted: #{orig_value}")

node.set['encrypted'] = Chef::EncryptedAttribute.create(orig_value)
node.save unless Chef::Config[:solo]
Chef::Log.info("Attribute encrypted: #{node['encrypted'].inspect}")

decrypted_attribute = Chef::EncryptedAttribute.load(node['encrypted'])
Chef::Log.info("Local attribute: #{decrypted_attribute.inspect}")
unless decrypted_attribute == orig_value
  fail 'Error reading the attribute locally.'
end

# Fails in Chef 12.0.0 and Chef 12.0.1
# Issue: https://github.com/opscode/chef/issues/2596
# Fix: https://github.com/opscode/chef/commit/
#      e809bb40b1340309c86edac9fb5cf7f179f8f7ec
req = Gem::Requirement.new('>= 12.0.0', '<= 12.0.1')
unless req.satisfied_by?(Gem::Version.new(Chef::VERSION))
  remote_decrypted_attribute =
    Chef::EncryptedAttribute.load_from_node(
      Chef::Config[:node_name],
      %w(encrypted)
    )
  Chef::Log.info("Remote attribute: #{remote_decrypted_attribute.inspect}")
  unless remote_decrypted_attribute == orig_value
    fail 'Error reading the attribute remotelly.'
  end
end
