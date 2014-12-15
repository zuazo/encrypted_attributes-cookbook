# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Library:: cookbook_helpers
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Internal `encrypted_attributes` cookbook classes and modules.
class EncryptedAttributesCookbook
  # Some helpers used in the `encrypted_attribute` cookbook.
  module Helpers
    # Checks if we are in Chef 12.
    #
    # @return [Boolean] `true` if we are in Chef `>= 12`.
    # @api private
    def self.chef12?
      Chef::VERSION.to_f >= 12
    end

    # Checks if we are in Chef `<= 11.12`.
    #
    # These versions of Chef have `yajl-ruby` gem as dependency.
    #
    # @return [Boolean] `true` if we are in Chef `<= 11.12`.
    # @api private
    def self.chef11old?
      Chef::VERSION.to_f <= 11.12
    end

    # Checks if we are in Chef `>= 11.14`.
    #
    # These versions of Chef have `ffi-yajl` gem as dependency.
    #
    # @return [Boolean] `true` if we are in Chef `>= 11.14`.
    # @api private
    def self.chef11new?
      !chef12? && !chef11old?
    end

    # Checks if we are going to install `chef-encrypted-attributes gem version
    # `< 0.4`.
    #
    # Gem versions `< 0.4` have `yajl-ruby` gem as dependency.
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` for gem version `< 0.4`.
    # @raise [RuntimeError] if specified gem version is wrong.
    # @api private
    def self.oldgem?(gem_version)
      return false if gem_version.nil?
      gem_version.to_f < 0.4
    rescue NoMethodError
      raise 'EncryptedAttributesCookbook: Wrong gem version set in '\
            'node["encrypted_attributes"]["version"].'
    end

    # Checks if we are going to install `chef-encrypted-attributes gem version
    # `>= 0.4`.
    #
    # Gem versions `>= 0.4` have `ffi-yajl` gem as dependency.
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` for gem version `>= 0.4`.
    # @raise [RuntimeError] if specified gem version is wrong.
    # @api private
    def self.newgem?(gem_version)
      !oldgem?(gem_version)
    end

    # Checks if `build-essential` cookbook is required.
    #
    # This is used only for native gems compilation.
    #
    # | **Gem Version**       | **0.4.0** *(latest)* | **0.3.0** |
    # |-----------------------|----------------------|-----------|
    # | **Chef `12`**         | no                   | -         |
    # | **Chef `>= 11.16.4`** | no                   | yes       |
    # | **Chef `< 11.16.4`**  | yes                  | no        |
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if `build-essential` cookbook is required.
    # @raise [RuntimeError] if specified gem version is wrong.
    def self.require_build_essential?(gem_version)
      (chef11old? && newgem?(gem_version)) ||
        (chef11new? && oldgem?(gem_version))
    end

    # Checks if gem dependencies should be installed or not.
    #
    # | **Gem Version**       | **0.4.0** *(latest)* | **0.3.0** |
    # |-----------------------|----------------------|-----------|
    # | **Chef `12`**         | yes                  | -         |
    # | **Chef `>= 11.16.4`** | yes                  | yes       |
    # | **Chef `< 11.16.4`**  | yes                  | yes       |
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if dependencies installation should be skipped.
    def self.skip_gem_dependencies?(_gem_version)
      true
    end

    # Gets required gem dependencies.
    #
    # We should return no dependencies if already included by Chef.
    #
    # | **Gem Version**       | **0.4.0** *(latest)* | **0.3.0** |
    # |-----------------------|----------------------|-----------|
    # | **Chef `12`**         | -                    | -         |
    # | **Chef `>= 11.16.4`** | -                    | yajl-ruby |
    # | **Chef `< 11.16.4`**  | ffi-yajl             | -         |
    #
    # @param gem_version [String] gem version to install.
    # @return [Hash<String, String>] list of gem dependencies required as
    #   `Hash<Name, Version>`.
    # @raise [RuntimeError] if specified gem version is wrong.
    def self.required_depends(gem_version)
      # TODO: Add dependency versions?
      if chef11new? && oldgem?(gem_version)
        { 'yajl-ruby' => nil }
      elsif chef11old? && newgem?(gem_version)
        { 'ffi-yajl' => nil }
      else
        {}
      end
    end

    # Checks if the gem version to install is a prerelease version.
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if it is a prerelease version.
    def self.prerelease?(gem_version)
      gem_version.is_a?(String) && gem_version.match(/^[0-9.]+$/).nil?
    end
  end
end
