class Chef
  class EncryptedAttribute

    def self.query
      @@query ||= Chef::Search::Query.new
    end

    def self.key
      OpenSSL::PKey::RSA.new(open(Chef::Config[:client_key]).read())
    end

    def self.public_key
      key.public_key
    end

    def self.encrypt(value, public_key)
      if public_key.kind_of?(String)
        public_key = OpenSSL::PKey::RSA.new(public_key)
      end
      Base64.encode64(public_key.public_encrypt(value))
    end

    def self.decrypt(value)
      key.private_decrypt(Base64.decode64(value))
    end

    # 403 Forbidden unless admin client or user
    # def self.load_users(names)
    #   users =
    #     if names.kind_of?(Array)
    #       names.map do |name|
    #         Chef::User.load(name).public_name
    #       end
    #     else
    #       Chef::User.list(true)
    #     end
    #   Hash[
    #     users.map do |user|
    #       [ user.name, user.public_key ]
    #     end
    #   ]
    # end

    def self.load_clients(search=nil)
      return Hash.new if search == false
      Hash[
        query.search(:client, search || 'admin:true').shift.map do |client|
          [ client.name, client.public_key ]
        end
      ]
    end

    def self.load(hs)
      unless hs.kind_of?(Hash) and hs.has_key?('_encryted_attribute') and
        hs['_encryted_attribute'] == true
        Chef::Log.warn("#{self.class.to_s}#load must receive an encrypted attribute. You pass #{hs.inspect}.")
        return hs
      end

      unless hs['value'].kind_of?(Hash) and hs['value'].has_key?(Chef::Config[:node_name]) and
        hs['value'][Chef::Config[:node_name]].kind_of?(String)
        Chef::Log.warn("Attribute cannot be decrypted by this node.")
        return nil
      end

      value = hs['value'][Chef::Config[:node_name]]
      decrypt(value)
    end

    def self.create(o, search=nil)
      result = Mash.new
      result['_encryted_attribute'] = true
      clients = load_clients
      clients[Chef::Config[:node_name]] = public_key

      value = o.to_json
      result['value'] = Mash.new(Hash[
        clients.map do |name, public_key|
          [ name, encrypt(value, public_key) ]
        end
      ])
      result
    end

  end
end
