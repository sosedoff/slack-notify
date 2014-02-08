require "spec_helper"

describe SlackNotify::Client do
  describe "#initialize" do
    it "requires team name" do
      expect { described_class.new(nil, nil) }.
        to raise_error ArgumentError, "Team name required"
    end

    it "requires token" do
      expect { described_class.new("foobar", nil) }.
        to raise_error ArgumentError, "Token required"
    end

    it "raises error on invalid team name" do
      names = ["foo bar", "foo $bar", "foo.bar"]

      names.each do |name|
        expect { described_class.new(name, "token") }.
          to raise_error "Invalid team name"
      end
    end
  end

  describe "#test" do
    let(:client) do
      described_class.new("foo", "token")
    end

    let(:payload) do
      {
        text: "This is a test message!",
        channel: "#general",
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
        channel: "#general",
        username: "webhookbot"
      )

      client.notify("Message")
    end

    it "sends message as default user" do
      client.stub(:send_payload) { true }

      expect(client).to receive(:send_payload).with(
        text: "Message",
        channel: "#general",
        username: "webhookbot"
      )

      client.notify("Message")
    end

    it "sends message to a specified channel" do
      client.stub(:send_payload) { true }

      expect(client).to receive(:send_payload).with(
        text: "Message",
        channel: "#mychannel",
        username: "webhookbot"
      )

      client.notify("Message", "#mychannel")
    end

    it "delivers payload" do
      stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=token").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "", :headers => {})

      expect(client.notify("Message")).to eq true
    end

    context "with multiple channels" do
      before do
        client.stub(:send_payload) { true }
      end

      it "delivers payload to multiple channels" do
        expect(client).to receive(:send_payload).exactly(2).times
        client.notify("Message", ["#channel1", "#channel2"])
      end
    end

    context "when pound symbol is missing" do
      before { client.stub(:send_payload).and_return(true) }

      it "adds pound symbol to channel name" do
        expect(client).to receive(:send_payload).with(text: "Message", username: "webhookbot", channel: "#foobar")
        client.notify("Message", "foobar")
      end
    end

    context "when team name is invalid" do
      before do
        stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=token").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 404, :body => "Line 1\nLine 2\nLine 3", :headers => {})
      end

      it "raises error" do
        expect { client.notify("Message") }.to raise_error SlackNotify::Error
      end
    end

    context "when token is invalid" do
      before do
        stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=token").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 500, :body => "No hooks", :headers => {})
      end

      it "raises error" do
        expect { client.notify("Message") }
          .to raise_error SlackNotify::Error, "No hooks"
      end
    end

    context "when channel is invalid" do
      before do
        stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=token").
         with(:body => {"{\"text\":\"message\",\"username\":\"webhookbot\",\"channel\":\"#foobar\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 500, :body => "Invalid channel specified", :headers => {})
      end

      it "raises error" do
        expect { client.notify("message", "foobar") }.
          to raise_error SlackNotify::Error, "Invalid channel specified"
      end
    end
  end
end