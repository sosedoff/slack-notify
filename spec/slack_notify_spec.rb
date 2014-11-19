require "spec_helper"

describe SlackNotify do
  describe ".new" do
    it "returns a client instance" do
      expect(SlackNotify.new(webhook_url: "foobar")).to be_a SlackNotify::Client
    end
  end
end