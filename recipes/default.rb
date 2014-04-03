#
# Cookbook Name:: encrypted_attributes
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

node.default['encrypted'] = Chef::EncryptedAttribute.create("OK")
node.save

Chef::Log.info("Attribute encrypted: #{node['encrypted'].inspect}")

encrypted_attribute = Chef::EncryptedAttribute.load(node['encrypted'])
Chef::Log.info("Local attribute: #{encrypted_attribute.inspect}")

remote_encrypted_attribute = Chef::EncryptedAttribute.load_from_node(Chef::Config[:node_name], ['encrypted'])
Chef::Log.info("Remote attribute: #{remote_encrypted_attribute.inspect}")
