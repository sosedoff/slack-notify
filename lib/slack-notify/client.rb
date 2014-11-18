require "json"
require "faraday"

module SlackNotify
  class Client
    include SlackNotify::Connection

    def initialize(options = {})
      @webhook_url  = options[:webhook_url]
      @username     = options[:username]
      @channel      = options[:channel]
      @icon_url     = options[:icon_url]
      @icon_emoji   = options[:icon_emoji]
      @link_names   = options[:link_names]
      @unfurl_links = options[:unfurl_links] || "1"

      if @webhook_url.nil?
        raise ArgumentError, "Webhook URL required"
      end
    end

    def test
      notify("Test Message")
    end

    def notify(text, channel = nil)
      delivery_channels(channel).each do |chan|
        payload = SlackNotify::Payload.new(
          text:         text,
          channel:      chan,
          username:     @username,
          icon_url:     @icon_url,
          icon_emoji:   @icon_emoji,
          link_names:   @link_names,
          unfurl_links: @unfurl_links
        )

        send_payload(payload)
      end

      true
    end

    private

    def delivery_channels(channel)
      [channel || @channel || "#general"].flatten.compact.uniq
    end
  end
end
