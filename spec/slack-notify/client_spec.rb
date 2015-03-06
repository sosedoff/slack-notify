require "spec_helper"

describe SlackNotify::Client do
  describe "#initialize" do
    it "requires webhook_url" do
      expect { described_class.new }.to raise_error ArgumentError, "Webhook URL required"
    end

    it "does not raise error when webhook_url is set" do
      expect { described_class.new(webhook_url: "foobar") }.not_to raise_error
    end
  end

  describe "#test" do
    let(:client) { described_class.new(webhook_url: "foobar") }

    before do
      client.stub(:notify)
      client.test
    end

    it "it sends a test message" do
      expect(client).to have_received(:notify).with("Test Message")
    end
  end

  describe "#notify" do
    let(:client) do
      described_class.new(webhook_url: "https://hooks.slack.com/services/foo/bar")
    end

    before do
      stub_request(:post, "https://hooks.slack.com/services/foo/bar").
       with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"unfurl_links\":\"1\"}"=>true},
            :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
       to_return(:status => 200, :body => "", :headers => {})
    end

    it "delivers payload" do
      expect(client.notify("Message")).to eq true
    end

    context "when icon_url is set" do
      let(:client) do
        described_class.new(
          webhook_url: "https://hooks.slack.com/services/foo/bar",
          icon_url: "foobar"
        )
      end

      before do
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
          with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"icon_url\":\"foobar\",\"unfurl_links\":\"1\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "includes url in payload" do
        client.notify("Message")
      end
    end

    context "when icon_emoji is set" do
      let(:client) do
        described_class.new(
          webhook_url: "https://hooks.slack.com/services/foo/bar",
          icon_emoji: "foobar"
        )
      end

      before do
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
          with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"icon_emoji\":\"foobar\",\"unfurl_links\":\"1\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "includes icon in payload" do
        client.notify("Message")
      end
    end

    context "when link_names is set" do
      let(:client) do
        described_class.new(
          webhook_url: "https://hooks.slack.com/services/foo/bar",
          link_names: 1
        )
      end

      before do
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
          with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"link_names\":1,\"unfurl_links\":\"1\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "includes link_names in payload" do
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
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"unfurl_links\":\"1\"}"=>true},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 404, :body => "Line 1\nLine 2\nLine 3", :headers => {})
      end

      it "raises error" do
        expect { client.notify("Message") }.to raise_error SlackNotify::Error
      end
    end

    context "when token is invalid" do
      before do
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
         with(:body => {"{\"text\":\"Message\",\"username\":\"webhookbot\",\"channel\":\"#general\",\"unfurl_links\":\"1\"}"=>true},
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
        stub_request(:post, "https://hooks.slack.com/services/foo/bar").
         with(:body => {"{\"text\":\"message\",\"username\":\"webhookbot\",\"channel\":\"#foobar\",\"unfurl_links\":\"1\"}"=>true},
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
