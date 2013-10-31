require "spec_helper"

describe SlackNotify::Client do
  describe "#initialize" do
    it "requires subdomain" do
      expect { described_class.new(nil, nil) }.
        to raise_error ArgumentError, "Subdomain required"
    end

    it "requires token" do
      expect { described_class.new("foobar", nil) }.
        to raise_error ArgumentError, "Token required"
    end
  end
end