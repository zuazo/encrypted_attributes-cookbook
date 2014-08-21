# encoding: UTF-8

name 'encrypted_attributes_test'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description <<-EOS
This cookbook is used with test-kitchen to test the parent, encrypted_attributes
cookbook.
EOS
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'encrypted_attributes'
