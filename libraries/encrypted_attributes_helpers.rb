# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Library:: encrypted_attributes_helpers
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

class Chef
  # Encrypted Attribute Helpers to use from recipes/resources
  module EncryptedAttributesHelpers
    attr_writer :encrypted_attributes_enabled

    def encrypted_attributes_include
      run_context.include_recipe 'encrypted_attributes'
      require 'chef-encrypted-attributes'
    end

    def attr_get_from_ary(attr_ary)
      attr_ary.reduce(node) do |n, k|
        n.respond_to?(:key?) && n.key?(k) ? n[k] : nil
      end
    end

    def attr_set_from_ary(attr_ary, value)
      last = attr_ary.pop
      node_attr = attr_ary.reduce(node.normal) do |a, k|
        a[k] = Mash.new unless a.key?(k)
        a[k]
      end
      node_attr[last] = value
      node.save unless Chef::Config[:solo]
      value
    end

    def attr_writable_from_ary(attr_ary)
      attr_ary.reduce(node.set) do |n, k|
        n.respond_to?(:key?) && n.key?(k) ? n[k] : nil
      end
    end

    def config_set(opt, val, klass = String)
      if val.is_a?(klass)
        Chef::Config[:encrypted_attributes][opt] = val
      else
        fail "Unknown configuration value for #{opt}, "\
          "you passed #{val.class.name}"
      end
    end

    def encrypted_attribute_exist?(raw_attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        if Chef::EncryptedAttribute.respond_to?(:exist?)
          Chef::EncryptedAttribute.exist?(raw_attr)
        else
          Chef::EncryptedAttribute.exists?(raw_attr)
        end
      else
        !raw_attr.nil?
      end
    end

    def encrypted_attribute_load(raw_attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.load(raw_attr)
      else
        raw_attr
      end
    end

    def encrypted_attribute_load_from_node(node, raw_attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.load_from_node(node, raw_attr)
      else
        nil
      end
    end

    def encrypted_attribute_create(value)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.create(value)
      else
        value
      end
    end

    def encrypted_attribute_update(attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.update(attr)
      else
        true
      end
    end

    def encrypted_attributes_enabled?
      if @encrypted_attributes_enabled.nil?
        !Chef::Config[:solo] && !node['dev_mode']
      else
        @encrypted_attributes_enabled == true
      end
    end

    def encrypted_attributes_disable
      @encrypted_attributes_enabled = false
    end

    def encrypted_attribute_read(attr_ary)
      attr_r = attr_get_from_ary(attr_ary)
      encrypted_attribute_load(attr_r)
    end

    def encrypted_attribute_read_from_node(node, attr_ary)
      encrypted_attribute_load_from_node(node, attr_ary)
    end

    def encrypted_attribute_write(attr_ary, &block)
      attr_r = attr_get_from_ary(attr_ary)
      if encrypted_attribute_exist?(attr_r)
        attr_w = attr_writable_from_ary(attr_ary)
        encrypted_attribute_update(attr_w)
        encrypted_attribute_load(attr_r)
      else
        value = block.call
        attr_set_from_ary(attr_ary, encrypted_attribute_create(value))
        value
      end
    end

    def encrypted_attributes_allow_clients(search)
      config_set(:client_search, search)
    end

    def encrypted_attributes_allow_nodes(search)
      config_set(:node_search, search)
    end
  end
end
