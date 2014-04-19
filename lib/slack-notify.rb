require "slack-notify/version"
require "slack-notify/error"
require "slack-notify/payload"

require "json"
require "faraday"

module SlackNotify
  class Client
    def initialize(team, token, options = {})
      @team     = team
      @token    = token
      @username = options[:username]
      @channel  = options[:channel]
      @icon_url = options[:icon_url]

      validate_arguments
    end

    def test
      notify("Test Message")
    end

    def notify(text, channel = nil)
      delivery_channels(channel).each do |chan|
        payload = SlackNotify::Payload.new(
          text: text,
          channel: chan,
          username: @username,
          icon_url: @icon_url
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
      @team =~ /^[a-z\d\-]+$/ ? true : false
    end

    def delivery_channels(channel)
      [channel || @channel || "#general"].flatten.compact.uniq
    end

    def send_payload(payload)
      conn = Faraday.new(hook_url, { timeout: 5, open_timeout: 5 }) do |c|
        c.use(Faraday::Request::UrlEncoded)
        c.adapter(Faraday.default_adapter)
      end

      response = conn.post do |req|
        req.body = JSON.dump(payload.to_hash)
      end

      handle_response(response)
    end

    def handle_response(response)
      unless response.success?
        if response.body.include?("\n")
          raise SlackNotify::Error
        else
          raise SlackNotify::Error.new(response.body)
        end
      end
    end

    def hook_url
      "#{base_url}/services/hooks/incoming-webhook?token=#{@token}"
    end

    def base_url
      "https://#{@team}.slack.com"
    end
  end
end
