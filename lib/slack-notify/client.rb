require "json"
require "faraday"

module SlackNotify
  class Client
    include SlackNotify::Connection

    def initialize(options = {})
      @team         = options[:team]
      @token        = options[:token]
      @username     = options[:username]
      @channel      = options[:channel]
      @icon_url     = options[:icon_url]
      @icon_emoji   = options[:icon_emoji]
      @link_names   = options[:link_names]
      @unfurl_links = options[:unfurl_links] || "1"

      validate_arguments
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

    def validate_arguments
      raise ArgumentError, "Team name required" if @team.nil?
      raise ArgumentError, "Token required"     if @token.nil?
      raise ArgumentError, "Invalid team name"  unless valid_team_name?
    end

    def valid_team_name?
      @team =~ /^[a-z\d\-]+$/i ? true : false
    end

    def delivery_channels(channel)
      [channel || @channel || "#general"].flatten.compact.uniq
    end
  end
end
