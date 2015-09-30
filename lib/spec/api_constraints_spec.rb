require 'spec_helper'
require 'api_constraints'

describe ApiConstraints do
  let(:api_constraints_v1) { ApiConstraints.new(version: 1) }
  let(:api_constraints_v2) { ApiConstraints.new(version: 2, default: true) }

  describe "matches?" do

    it "returns true when the version matches the 'Accept' header" do
      request = double(host: 'api.localhost:3000',
                       headers: {"Accept" => "application/vnd.marketplace.v1"})
      api_constraints_v1.matches?(request).should be_truthy
    end

    it "returns the default version when 'default' option is specified" do
      request = double(host: 'api.localhost:3000')
      api_constraints_v2.matches?(request).should be_truthy
    end
  end
end