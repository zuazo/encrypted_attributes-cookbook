# encoding: UTF-8

class Chef
  # Encrypted Attribute Helpers to use from recipes/resources
  module EncryptedAttributesHelpers
    attr_writer :encrypted_attributes_enabled

    def encrypted_attributes_include
      include_recipe 'encrypted_attributes'
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
      node.save
      value
    end

    def attr_writable_from_ary(attr_ary)
      attr_ary.reduce(node.set) do |n, k|
        n.respond_to?(:key?) && n.key?(k) ? n[k] : nil
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
      if search.is_a?(String)
        Chef::Config[:encrypted_attributes][:client_search] = search
      else
        fail 'Unknown #encrypted_attributes_allow_clients argument, '\
          "you passed #{search.class.name}"
      end
    end

    def encrypted_attributes_allow_nodes(search)
      if search.is_a?(String)
        Chef::Config[:encrypted_attributes][:node_search] = search
      else
        fail 'Unknown #encrypted_attributes_allow_nodes argument, '\
          "you passed #{search.class.name}"
      end
    end
  end
end
