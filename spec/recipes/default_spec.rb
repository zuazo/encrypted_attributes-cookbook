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

require_relative '../spec_helper'

class Chef
  # make `Kernel#require` mockable
  class Recipe
    def require(string)
      Kernel.require(string)
    end
  end
end

describe 'encrypted_attributes::default' do
  before do
    allow(Kernel).to receive(:require).with('chef-encrypted-attributes')
  end
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'should install chef-encrypted-attributes gem' do
    expect(chef_run).to install_chef_gem('chef-encrypted-attributes')
  end

  it 'should require chef-encrypted-attributes gem' do
    expect(Kernel).to receive(:require).with('chef-encrypted-attributes')
    chef_run
  end

end
