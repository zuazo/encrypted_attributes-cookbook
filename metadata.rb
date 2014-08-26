# encoding: UTF-8

name 'encrypted_attributes'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description 'Installs and enables chef-encrypted-attributes gem: Chef plugin '\
  'to add Node encrypted attributes support using client keys.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0' # WiP

depends 'build-essential'

recipe 'encrypted_attributes::default',
       'Installs and loads the chef-encrypted-attributes gem.'
recipe 'encrypted_attributes::users_data_bag',
       'Configures chef-encrypted-attributes Chef User keys reading them from '\
       'a data bag. This is a workaround for the Chef Users Limitation problem.'

attribute 'encrypted_attributes/version',
          display_name: 'chef-encrypted-attributes version',
          description: 'chef-encrypted-attributes gem version to install. '\
            'The latest stable version is installed by default.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'encrypted_attributes/mirror',
          display_name: 'chef-encrypted-attributes mirror',
          description: 'chef-encrypted-attributes mirror to download the gem '\
            'from. For cases where you do not want to use rubygems.',
          type: 'string',
          required: 'optional',
          default: 'nil'

attribute 'encrypted_attributes/data_bag/name',
          display_name: 'chef-encrypted-attributes data bag name',
          description: 'chef-encrypted-attributes user keys data bag name.',
          type: 'string',
          required: 'optional',
          default: '"global"'

attribute 'encrypted_attributes/data_bag/item',
          display_name: 'chef-encrypted-attributes data bag item name',
          description:
            'chef-encrypted-attributes user keys data bag item name.',
          type: 'string',
          required: 'optional',
          default: '"chef_users"'

attribute 'dev_mode',
          display_name: 'dev mode',
          description: 'If this is true, the Chef::EncryptedAttributesHelpers '\
            'library will work with clear attributes instead of encrypted '\
            'attributes.',
          type: 'string',
          required: 'optional',
          calculated: true
