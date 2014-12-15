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
require 'encrypted_attributes_requirements'

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

  it 'loads chef-encrypted-attributes gem' do
    expect(Chef::EncryptedAttributesRequirements)
      .to receive(:require).with('chef/encrypted_attributes')
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
        .with_options(/--prerelease/)
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

  [
    { chef_version: '12.0.0',  gem_version: nil,     builds: false },
    { chef_version: '12.0.0',  gem_version: '0.4.0', builds: false },
    { chef_version: '11.16.4', gem_version: nil,     builds: false },
    { chef_version: '11.16.4', gem_version: '0.4.0', builds: false },
    { chef_version: '11.16.4', gem_version: '0.3.0', builds: true  },
    { chef_version: '11.12.8', gem_version: nil,     builds: true  },
    { chef_version: '11.12.8', gem_version: '0.4.0', builds: true  },
    { chef_version: '11.12.8', gem_version: '0.3.0', builds: false }
  ].each do |test|
    context "with Chef #{test[:chef_version].inspect} and gem version"\
            " #{test[:gem_version].inspect}" do
      before do
        stub_const('Chef::VERSION', test[:chef_version])
        node.set['encrypted_attributes']['version'] = test[:gem_version]
      end

      if test[:builds]
        it 'includes build-essential recipe' do
          expect(chef_run).to include_recipe('build-essential')
        end

        it 'installs chef-encrypted-attributes dependencies' do
          expect(chef_run).to_not install_chef_gem('chef-encrypted-attributes')
            .with_version(test[:gem_version])
            .with_options(/--ignore-dependencies/)
        end
      else
        it 'includes build-essential recipe' do
          expect(chef_run).to_not include_recipe('build-essential')
        end

        it 'installs chef-encrypted-attributes dependencies' do
          expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
            .with_version(test[:gem_version])
            .with_options(/--ignore-dependencies/)
        end
      end # else test[:builds]
    end # context with Chef x and gem version y
  end # each test
end
