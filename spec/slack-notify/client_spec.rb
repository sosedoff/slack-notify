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

  describe "#test" do
    let(:client) do
      described_class.new("foo", "token")
    end

    let(:payload) do
      {
        text: "This is a test message!",
        channel: "general",
        username: "webhookbot"
      }
    end

    before do
      client.stub(:send_payload) { true }
    end

    it "sends a test payload" do
      expect(client).to receive(:send_payload).with(payload)
      client.test
    end
  end

  describe "#notify" do
    let(:client) do
      described_class.new("foo", "token")
    end

    it "sends message to default channel" do
      client.stub(:send_payload) { true }

      expect(client).to receive(:send_payload).with(
        text: "Message",
        channel: "general",
        username: "webhookbot"
      )

      client.notify("Message")
    end

    it "sends message as default user" do
      client.stub(:send_payload) { true }

      expect(client).to receive(:send_payload).with(
        text: "Message",
        channel: "general",
        username: "webhookbot"
      )

      client.notify("Message")
    end

    it "sends message to a specified channel" do
      client.stub(:send_payload) { true }

      expect(client).to receive(:send_payload).with(
        text: "Message",
        channel: "mychannel",
        username: "webhookbot"
      )

      client.notify("Message", "mychannel")
    end

    it "delivers payload" do
      stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook").
         with(:body => {"{\"text\":\"Message\",\"channel\":\"general\",\"username\":\"webhookbot\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.8.8'}).
         to_return(:status => 200, :body => "", :headers => {})

      expect(client.notify("Message")).to eq true
    end
  end
end