#
# Cookbook Name:: encrypted_attributes_test
# Recipe:: default
#
# Copyright 2014, Onddo Labs, Sl.
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

orig_value = { 'a_key' => 'Some random string', 'primitives' => [ 0, 0.2, true, false, nil ] }

Chef::Log.info("Attribute decrypted: #{orig_value}")

node.default['encrypted'] = Chef::EncryptedAttribute.create(orig_value)
node.save unless Chef::Config[:solo]
Chef::Log.info("Attribute encrypted: #{node['encrypted'].inspect}")

decrypted_attribute = Chef::EncryptedAttribute.load(node['encrypted'])
Chef::Log.info("Local attribute: #{decrypted_attribute.inspect}")
unless decrypted_attribute == orig_value
  raise 'Error reading the attribute locally.'
end

remote_decrypted_attribute = Chef::EncryptedAttribute.load_from_node(Chef::Config[:node_name], ['encrypted'])
Chef::Log.info("Remote attribute: #{remote_decrypted_attribute.inspect}")
unless remote_decrypted_attribute == orig_value
  raise 'Error reading the attribute remotelly.'
end
