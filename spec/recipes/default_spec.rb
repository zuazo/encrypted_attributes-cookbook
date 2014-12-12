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

class Chef
  # make `Kernel#require` mockable
  class Recipe
    def require(string)
      Kernel.require(string)
    end
  end
end

describe 'encrypted_attributes::default', order: :random do
  before do
    allow(Kernel).to receive(:require).with('chef/encrypted_attributes')
  end
  let(:chef_runner) { ChefSpec::ServerRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }

  it 'installs chef-encrypted-attributes gem' do
    expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
  end

  it 'requires chef-encrypted-attributes gem' do
    expect(Kernel).to receive(:require).with('chef/encrypted_attributes')
    chef_run
  end

  context 'with specific version' do
    let(:version) { '0.3.0' }
    before { node.set['encrypted_attributes']['version'] = version }

    it 'installs chef-encrypted-attributes gem specific version' do
      expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
        .with_version(version)
    end
  end

  context 'with prerelease version' do
    let(:version) { '0.5.0.beta' }
    before { node.set['encrypted_attributes']['version'] = version }

    it 'installs chef-encrypted-attributes gem prerelease version' do
      expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
        .with_version(version)
        .with_options('--prerelease')
    end
  end

  context 'with FreeBSD' do
    let(:chef_runner) do
      ChefSpec::ServerRunner.new(platform: 'freebsd', version: '9.2')
    end

    it 'sets freebsd cookbook compile time' do
      chef_run
      expect(node['freebsd']['compiletime_portsnap']).to be(true)
    end
  end # context with FreeBSD

end
