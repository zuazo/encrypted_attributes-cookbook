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
    # <table>
    #   <tr>
    #     <th><code>build-essential?</code></th>
    #     <th><code>0.4.0</code> <em>(latest)</em></th>
    #     <th><code>0.3.0</code></th>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>12</code></th>
    #     <td>no</td>
    #     <td>-</td>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>&ge; 11.16.4</code></th>
    #     <td>no</td>
    #     <td>yes</td>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>&lt; 11.16.4</code></th>
    #     <td>yes</td>
    #     <td>no</td>
    #   </tr>
    # </table>
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
    # We should skip installing gem dependencies if already included by Chef.
    #
    # <table>
    #   <tr>
    #     <th><code>--ignore-dependencies</code></th>
    #     <th><code>0.4.0</code> <em>(latest)</em></th>
    #     <th><code>0.3.0</code></th>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>12</code></th>
    #     <td>yes</td>
    #     <td>-</td>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>&ge; 11.16.4</code></th>
    #     <td>yes</td>
    #     <td>no</td>
    #   </tr>
    #   <tr>
    #     <th>Chef <code>&lt; 11.16.4</code></th>
    #     <td>no</td>
    #     <td>yes</td>
    #   </tr>
    # </table>
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if dependencies installation should be skipped.
    # @raise [RuntimeError] if specified gem version is wrong.
    def self.skip_gem_dependencies?(gem_version)
      # == !require_build_essential?(gem_version)
      chef12? || (chef11old? && oldgem?(gem_version)) ||
        (chef11new? && newgem?(gem_version))
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
