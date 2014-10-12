encrypted_attributes CHANGELOG
==============================

This file is used to list changes made in each version of the `encrypted_attributes` cookbook.

## v0.3.0 (2014-10-21)

* Add FreeBSD support
* Berksfile, Rakefile and Guarfile, generic templates copied
* Added `rubocop.yml` with *AllCops:Include*
* README:
 * Add an example to encrypt MySQL passwords
 * Always include encrypted_attributes recipe to force compile time build-essentials
 * Use single quotes in examples
 * Use markdown for tables
* Add LICENSE file
* kitchen.yml: remove empty attributes key
* License headers homogenized

## v0.2.2 (2014-10-02)

* Added platform support documentation
* `kitchen.yml` file updated
* Rakefile: rubocop enabled
* Gemfile:
  * Replaced vagrant by vagrant-wrapper
  * Added vagrant-wrapper version with pessimistic operator
  * Berkshelf updated to 3.1
* Guardfile added
* TODO: use checkboxes

## v0.2.1 (2014-08-28)

* EncryptedAttributesHelpers bugfix: avoid `#node.save` on chef-solo
* EncryptedAttributesHelpers: some code duplication removed
* README: added gemnasium and codeclimate badges

## v0.2.0 (2014-08-26)

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
* Added RuboCop checking, all offenses fixed
* TODO: added verify gem task
* test/kitchen directory removed

## v0.1.0 (2014-05-22)

* Initial release of `encrypted_attributes`
