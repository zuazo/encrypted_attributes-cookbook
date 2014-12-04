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

describe 'encrypted_attributes::expose_key', order: :random do
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_run.node }

  context 'with Chef-Server' do
    let(:chef_runner) do
      ChefSpec::ServerRunner.new do |node, server|
        server.create_client(node.name, admin: false)
      end
    end

    it 'runs without errors' do
      chef_run
    end

    it 'exposes public_key' do
      chef_run
      expect(node['public_key']).to be_a(String)
    end
  end # context with Chef-Server

  context 'with Chef-Solo' do
    let(:chef_runner) { ChefSpec::SoloRunner.new }

    it 'runs without errors' do
      chef_run
    end

    it 'does not expose public_key' do
      chef_run
      expect(node['public_key']).to be(nil)
    end
  end # context with Chef-Solo
end
