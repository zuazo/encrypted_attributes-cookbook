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
require 'cookbook_helpers'

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
    { chef: '12.0.0',  gem: nil,     build: false, depend: nil         },
    { chef: '12.0.0',  gem: '0.7.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '12.0.0',  gem: '0.7.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '12.0.0',  gem: '0.6.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '12.0.0',  gem: '0.6.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '12.0.0',  gem: '0.4.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '12.0.0',  gem: '0.4.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '11.16.4', gem: nil,                    build: false, depend: nil },
    { chef: '11.16.4', gem: '0.7.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.16.4', gem: '0.7.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '11.16.4', gem: '0.6.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.16.4', gem: '0.6.0', ruby: '1.9.2', build: true,  depend: nil },
    { chef: '11.16.4', gem: '0.4.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.16.4', gem: '0.4.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '11.16.4', gem: '0.3.0', ruby: '2.1.0', build: true,
      depend: 'yajl-ruby' },
    { chef: '11.16.4', gem: '0.3.0', ruby: '1.9.2', build: true,
      depend: 'yajl-ruby' },
    { chef: '11.12.8', gem: nil,     build: false, depend: nil         },
    { chef: '11.12.8', gem: '0.7.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.12.8', gem: '0.7.0', ruby: '1.9.2', build: false, depend: nil },
    { chef: '11.12.8', gem: '0.6.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.12.8', gem: '0.6.0', ruby: '1.9.2', build: true,  depend: nil },
    { chef: '11.12.8', gem: '0.4.0', ruby: '2.1.0', build: true,
      depend: 'ffi-yajl' },
    { chef: '11.12.8', gem: '0.4.0', ruby: '1.9.2', build: true,
      depend: 'ffi-yajl' },
    { chef: '11.12.8', gem: '0.3.0', ruby: '2.1.0', build: false, depend: nil },
    { chef: '11.12.8', gem: '0.3.0', ruby: '1.9.2', build: false, depend: nil }
  ].each do |test|
    context "with Chef #{test[:chef].inspect}, gem version"\
            " #{test[:gem].inspect} and ruby version"\
            " #{test[:ruby].inspect}" do
      before do
        stub_const('Chef::VERSION', test[:chef])
        unless test[:ruby].nil?
          helpers_class = EncryptedAttributesCookbook::Helpers.name
          stub_const("#{helpers_class}::RUBY_VERSION", test[:ruby])
        end
        node.set['encrypted_attributes']['version'] = test[:gem]
      end

      it 'includes build-essential recipe', if: test[:build] do
        expect(chef_run).to include_recipe('build-essential')
      end

      it 'does not include build-essential recipe', unless: test[:build] do
        expect(chef_run).to_not include_recipe('build-essential')
      end

      it "installs #{test[:depend].inspect} dependency gem",
         unless: test[:depend].nil? do
        expect(chef_run).to install_chef_gem(test[:depend])
      end

      it 'installs chef-encrypted-attributes dependencies' do
        expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
          .with_version(test[:gem])
          .with_options(/--ignore-dependencies/)
      end
    end # context with Chef x and gem version y
  end # each test
end
