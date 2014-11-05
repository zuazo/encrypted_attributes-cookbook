# encoding: UTF-8
#
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

require 'spec_helper'

describe 'encrypted_attributes::users_data_bag', order: :random do
  before do
    @bob_key = OpenSSL::PKey::RSA.new(2048).public_key.to_s.strip
    @alice_key = OpenSSL::PKey::RSA.new(2048).public_key.to_s.strip
    @data_bag_item = {
      'id' => 'chef_users',
      'chef_type' => 'data_bag_item',
      'data_bag' => 'global',
      'bob' => @bob_key, # as String
      'alice' => @alice_key.split("\n"), # as Array
    }
    Chef::Config[:encrypted_attributes] = Mash.new
    Chef::Config[:encrypted_attributes][:keys] = nil
    allow(Chef::DataBagItem).to receive(:load).and_return(@data_bag_item)
    allow(Kernel).to receive(:require).with('chef-encrypted-attributes')
  end
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'includes encrypted_attributes::default recipe' do
    expect(chef_run).to include_recipe('encrypted_attributes::default')
  end

  it 'reads the data bag' do
    expect(Chef::DataBagItem).to receive(:load).with('global', 'chef_users')
      .and_return(@data_bag_item)
    chef_run
  end

  it 'sets the configuration keys' do
    chef_run
    expect(Chef::Config[:encrypted_attributes][:keys])
      .to eql([@bob_key, @alice_key])
  end

end
