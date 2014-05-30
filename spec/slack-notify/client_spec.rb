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
    let(:client) { described_class.new("foo", "token") }

    before do
      client.stub(:notify)
      client.test
    end

    it "it sends a test message" do
      expect(client).to have_received(:notify).with("Test Message")
    end
  end

  describe "#notify" do
    let(:client) { described_class.new("foo", "token") }

    it "delivers payload" do
      stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=token").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "", :headers => {})

      expect(client.notify("Message")).to eq true
    end

    context "with settings from environment variables" do
      let(:vars) { ["SLACK_TEAM", "SLACK_TOKEN", "SLACK_CHANNEL", "SLACK_USER"] }

      let(:client) do
        described_class.new(ENV["SLACK_TEAM"], ENV["SLACK_TOKEN"], {
          channel: ENV["SLACK_CHANNEL"],
          username: ENV["SLACK_USER"]
        })
      end

      before do
        vars.each { |v| ENV[v] = "foobar" }
        client.stub(:send_payload) { true }
      end

      after do
        vars.each { |v| ENV.delete(v) }
      end

      it "sends data to channel specified by environment variables" do
        client.notify("Message")
      end
    end

    context "when icon_url is set" do
      let(:client) { described_class.new("foo", "bar", icon_url: "foobar") }

      before do
        stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=bar").
          with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"icon_url\":\"foobar\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.0'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "includes url in payload" do
        client.notify("Message")
      end
    end

    context "when icon_emoji is set" do
      let(:client) { described_class.new("foo", "bar", icon_emoji: "foobar") }

      before do
        stub_request(:post, "https://foo.slack.com/services/hooks/incoming-webhook?token=bar").
          with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"icon_emoji\":\"foobar\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.0'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "includes icon in payload" do
        client.notify("Message")
      end
    end

    context "with multiple channels" do
      before do
        client.stub(:send_payload) { true }
        client.notify("Message", ["#channel1", "#channel2"])
      end

      it "delivers payload to multiple channels" do
        expect(client).to have_received(:send_payload).exactly(2).times
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
