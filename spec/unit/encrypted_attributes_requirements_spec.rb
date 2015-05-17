# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL. (www.onddo.com)
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

require 'spec_helper'
require 'encrypted_attributes_requirements'

describe Chef::EncryptedAttributesRequirements, order: :random do
  context '.load' do
    after { Chef::EncryptedAttributesRequirements.load }

    it 'requires chef/encrypted_attributes' do
      expect(Chef::EncryptedAttributesRequirements)
        .to receive('require').with('chef/encrypted_attributes').once
    end

    context 'with chef/encrypted_attributes LoadError' do
      before do
        allow(Chef::EncryptedAttributesRequirements)
          .to receive('require').with('chef/encrypted_attributes')
          .and_raise(
            LoadError.new(
              'LoadError: cannot load such file -- chef/encrypted_attributes'
            )
          )
        allow(Chef::EncryptedAttributesRequirements)
          .to receive('require').with('chef-encrypted-attributes')
          .and_return(true)
        allow(Chef::Log).to receive(:warn)
      end

      it 'requires chef-encrypted-attributes' do
        expect(Chef::EncryptedAttributesRequirements)
          .to receive('require').with('chef-encrypted-attributes').once
          .and_return(true)
      end

      it 'prints a Chef warning' do
        expect(Chef::Log).to receive(:warn).with(
          'Old chef-encrypted-attributes gem detected, please upgrade ASAP.'
        )
      end
    end # context with chef/encrypted_attributes LoadError
  end # context .load
end
