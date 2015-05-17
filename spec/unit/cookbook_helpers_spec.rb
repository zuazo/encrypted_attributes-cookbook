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
require 'cookbook_helpers.rb'

describe EncryptedAttributesCookbook::Helpers, order: :random do
  let(:helpers) { described_class }

  context '.require_build_essential?' do
    [
      { chef: '12.0.0',  gem: nil,                    result: false },
      { chef: '12.0.0',  gem: '0.7.0', ruby: '2.1.0', result: false },
      { chef: '12.0.0',  gem: '0.7.0', ruby: '1.9.2', result: false },
      { chef: '12.0.0',  gem: '0.6.0', ruby: '2.1.0', result: false },
      { chef: '12.0.0',  gem: '0.6.0', ruby: '1.9.2', result: false },
      { chef: '12.0.0',  gem: '0.4.0', ruby: '2.1.0', result: false },
      { chef: '12.0.0',  gem: '0.4.0', ruby: '1.9.2', result: false },
      { chef: '11.16.4', gem: nil,                    result: false },
      { chef: '11.16.4', gem: '0.7.0', ruby: '2.1.0', result: false },
      { chef: '11.16.4', gem: '0.7.0', ruby: '1.9.2', result: false },
      { chef: '11.16.4', gem: '0.6.0', ruby: '2.1.0', result: false },
      { chef: '11.16.4', gem: '0.6.0', ruby: '1.9.2', result: true  },
      { chef: '11.16.4', gem: '0.4.0', ruby: '2.1.0', result: false },
      { chef: '11.16.4', gem: '0.4.0', ruby: '1.9.2', result: false },
      { chef: '11.16.4', gem: '0.3.0', ruby: '2.1.0', result: true  },
      { chef: '11.16.4', gem: '0.3.0', ruby: '1.9.2', result: true  },
      { chef: '11.12.8', gem: nil,                    result: false },
      { chef: '11.12.8', gem: '0.7.0', ruby: '2.1.0', result: false },
      { chef: '11.12.8', gem: '0.7.0', ruby: '1.9.2', result: false },
      { chef: '11.12.8', gem: '0.6.0', ruby: '2.1.0', result: false },
      { chef: '11.12.8', gem: '0.6.0', ruby: '1.9.2', result: true  },
      { chef: '11.12.8', gem: '0.4.0', ruby: '2.1.0', result: true  },
      { chef: '11.12.8', gem: '0.4.0', ruby: '1.9.2', result: true  },
      { chef: '11.12.8', gem: '0.3.0', ruby: '2.1.0', result: false },
      { chef: '11.12.8', gem: '0.3.0', ruby: '1.9.2', result: false },
      { chef: '11.6.0',  gem: nil,                    result: false },
      { chef: '11.6.0',  gem: '0.7.0', ruby: '2.1.0', result: false },
      { chef: '11.6.0',  gem: '0.7.0', ruby: '1.9.2', result: false },
      { chef: '11.6.0',  gem: '0.6.0', ruby: '2.1.0', result: false },
      { chef: '11.6.0',  gem: '0.6.0', ruby: '1.9.2', result: true  },
      { chef: '11.6.0',  gem: '0.4.0', ruby: '2.1.0', result: true  },
      { chef: '11.6.0',  gem: '0.4.0', ruby: '1.9.2', result: true  },
      { chef: '11.6.0',  gem: '0.3.0', ruby: '2.1.0', result: false },
      { chef: '11.6.0',  gem: '0.3.0', ruby: '1.9.2', result: false }
    ].each do |test|
      context "with Chef #{test[:chef].inspect}, gem version"\
              " #{test[:gem].inspect} and ruby version"\
              " #{test[:ruby].inspect}" do
        before do
          stub_const('Chef::VERSION', test[:chef])
          unless test[:ruby].nil?
            stub_const("#{helpers}::RUBY_VERSION", test[:ruby])
          end
        end

        it "returns #{test[:result].inspect}" do
          expect(helpers.require_build_essential?(test[:gem]))
            .to be(test[:result])
        end
      end # context with Chef x and gem version y
    end # each test

    it 'raises an error if gem version is wrong' do
      stub_const('Chef::VERSION', '11.12.8')
      expect { helpers.require_build_essential?(Object.new) }
        .to raise_error(/EncryptedAttributesCookbook: Wrong gem version set/)
    end
  end # context .require_build_essential?

  context '.skip_gem_dependencies?' do
    [
      { chef: '12.0.0',  gem: nil,     result: true },
      { chef: '12.0.0',  gem: '0.6.0', result: true },
      { chef: '12.0.0',  gem: '0.4.0', result: true },
      { chef: '11.16.4', gem: nil,     result: true },
      { chef: '11.16.4', gem: '0.6.0', result: true },
      { chef: '11.16.4', gem: '0.4.0', result: true },
      { chef: '11.16.4', gem: '0.3.0', result: true },
      { chef: '11.12.8', gem: nil,     result: true },
      { chef: '11.12.8', gem: '0.6.0', result: true },
      { chef: '11.12.8', gem: '0.4.0', result: true },
      { chef: '11.12.8', gem: '0.3.0', result: true },
      { chef: '11.6.0',  gem: nil,     result: true },
      { chef: '11.6.0',  gem: '0.6.0', result: true },
      { chef: '11.6.0',  gem: '0.4.0', result: true },
      { chef: '11.6.0',  gem: '0.3.0', result: true }
    ].each do |test|
      context "with Chef #{test[:chef].inspect} and gem version"\
              " #{test[:gem].inspect}" do
        before { stub_const('Chef::VERSION', test[:chef]) }

        it "returns #{test[:result].inspect}" do
          expect(helpers.skip_gem_dependencies?(test[:gem]))
            .to be(test[:result])
        end
      end # context with Chef x and gem version y
    end # each test
  end # context .skip_gem_dependencies?

  context '.required_depends' do
    [
      { chef: '12.0.0',  gem: nil,     result: nil              },
      { chef: '12.0.0',  gem: '0.6.0', result: nil              },
      { chef: '12.0.0',  gem: '0.4.0', result: nil              },
      { chef: '11.16.4', gem: nil,     result: nil              },
      { chef: '11.16.4', gem: '0.6.0', result: nil              },
      { chef: '11.16.4', gem: '0.4.0', result: nil              },
      { chef: '11.16.4', gem: '0.3.0', result: 'yajl-ruby'      },
      { chef: '11.12.8', gem: nil,     result: nil              },
      { chef: '11.12.8', gem: '0.6.0', result: nil              },
      { chef: '11.12.8', gem: '0.4.0', result: 'ffi-yajl@1.0.2' },
      { chef: '11.12.8', gem: '0.3.0', result: nil              },
      { chef: '11.6.0',  gem: nil,     result: nil              },
      { chef: '11.6.0',  gem: '0.6.0', result: nil              },
      { chef: '11.6.0',  gem: '0.4.0', result: 'ffi-yajl@1.0.2' },
      { chef: '11.6.0',  gem: '0.3.0', result: nil              }
    ].each do |test|
      result, result_version =
        test[:result].is_a?(String) ? test[:result].split('@', 2) : nil

      context "with Chef #{test[:chef].inspect} and gem version"\
              " #{test[:gem].inspect}" do
        before { stub_const('Chef::VERSION', test[:chef]) }

        it "returns #{test[:result].inspect} as dependency" do
          result = result.nil? ? {} : { result => result_version }
          expect(helpers.required_depends(test[:gem]))
            .to eq(result)
        end
      end # context with Chef x and gem version y
    end # each test

    it 'raises an error if gem version is wrong' do
      stub_const('Chef::VERSION', '11.12.8')
      expect { helpers.required_depends(Object.new) }
        .to raise_error(/EncryptedAttributesCookbook: Wrong gem version set/)
    end
  end # context .required_depends

  context '.prerelease?' do
    {
      nil => false,
      '0.3.0.dev' => true,
      '0.3.0' => false,
      '0.4.0.dev' => true,
      '0.4.0.beta.0' => true,
      '0.4.0' => false,
      '0.6.0.beta.2' => true,
      '0.6.0' => false
    }.each do |version, result|
      context "with version #{version.inspect}" do
        it "returns #{result.inspect}" do
          expect(helpers.prerelease?(version)).to eq(result)
        end
      end # context with version
    end # each version, result
  end # context .prerelease?
end
