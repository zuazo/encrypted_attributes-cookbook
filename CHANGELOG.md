encrypted_attributes CHANGELOG
==============================

This file is used to list changes made in each version of the `encrypted_attributes` cookbook.

## 0.2.0:

* `encrypted_attributes_test::default`: `node#save` unless chef-solo
* Gemfile:
 * RSpec `~> 2.14.0` to avoid `uninitialized constant RSpec::Matchers::BuiltIn::RaiseError::MatchAliases` error
 * Updates: ChefSpec `4` and foodcritic `4`
 * Added chef-encrypted-attributes gem for unit tests
 * Gemfile clean up
* README:
 * README file split in multiple files
 * Replace community links by Supermarket links
 * Fixed `::users_data_bag` example using `#exist?` instead of `#exists_on_node?`
 * Added a link to `chef-encrypted-attributes` gem requirements
 * Multiple small fixes and improvements
* `::default`: avoid gem install error when no version is specified
* Install `gcc` dependency (`build-essential` cookbook)
* Added `Chef::EncryptedAttributesHelpers` helper library
 * Added `EncryptedAttributesHelpers` unit tests
* Added RuboCop checking, all ofenses fixed
* TODO: added verify gem task
* test/kitchen directory removed

## 0.1.0:

* Initial release of `encrypted_attributes`
