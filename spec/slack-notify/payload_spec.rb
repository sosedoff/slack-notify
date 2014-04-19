require "spec_helper"

describe SlackNotify::Payload do
  let(:options) do
    {
      username: "foo",
      channel: "#bar",
      text: "hola",
      icon_url: "http://domain.com/image.png",
      icon_emoji: ":chart_with_upwards_trend:"
    }
  end

  describe "#initialize" do
    let(:payload) { described_class.new(options) }

    context "with options" do
      it "sets username" do
        expect(payload.username).to eq "foo"
      end

      it "sets channel" do
        expect(payload.channel).to eq "#bar"
      end

      it "sets text" do
        expect(payload.text).to eq "hola"
      end

      it "sets icon url" do
        expect(payload.icon_url).to eq "http://domain.com/image.png"
      end

      it "sets icon emoji" do
        expect(payload.icon_emoji).to eq ":chart_with_upwards_trend:"
      end

      context "on missing pound in channel" do
        let(:options) do
          { channel: "foo" }
        end

        it "adds pound symbol" do
          expect(payload.channel).to eq "#foo"
        end
      end

      context "on direct message" do
        let(:options) do
          { channel: "@dan" }
        end

        it "keeps the symbol" do
          expect(payload.channel).to eq "@dan"
        end
      end
    end

    context "without options" do
      let(:options) { Hash.new }

      it "sets username" do
        expect(payload.username).to eq "webhookbot"
      end

      it "sets channel" do
        expect(payload.channel).to eq "#general"
      end
    end
  end

  describe "#to_hash" do
    let(:hash) { described_class.new(options).to_hash }

    it "includes basic attributes" do
      expect(hash).to eq Hash(
        channel: "#bar",
        icon_url: "http://domain.com/image.png",
        icon_emoji: ":chart_with_upwards_trend:",
        text: "hola",
        username: "foo"
      )
    end

    context "when icon url is not set" do
      before do
        options[:icon_url] = nil
      end

      it "excludes icon_url" do
        expect(hash.keys).not_to include "icon_url"
      end
    end

    context "when icon emoji is not set" do
      before do
        options[:icon_emoji] = nil
      end

      it "excludes icon_emoji" do
        expect(hash.keys).not_to include "icon_emoji"
      end
    end
  end
end