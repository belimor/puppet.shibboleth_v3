require 'spec_helper'
describe 'shibboleth_v3' do

  context 'with defaults for all parameters' do
    it { should contain_class('shibboleth_v3') }
  end
end
