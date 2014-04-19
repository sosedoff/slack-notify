require "slack-notify/version"
require "slack-notify/error"

require "json"
require "faraday"

module SlackNotify
  class Client
    def initialize(team, token, options = {})
      @team     = team
      @token    = token
      @username = options[:username] || "webhookbot"
      @channel  = options[:channel]  || "#general"
      @icon_url = options[:icon_url]

      validate_arguments
    end

    def test
      notify("This is a test message!")
    end

    def notify(text, channel = nil)
      format_channel(channel).each do |chan|
        send_payload(text: text, username: @username, channel: chan)
      end

      true
    end

    private

    def validate_arguments
      raise ArgumentError, "Team name required" if @team.nil?
      raise ArgumentError, "Token required"     if @token.nil?
      raise ArgumentError, "Invalid team name"  unless valid_team_name?
    end

    def format_channel(channel)
      [channel || @channel].flatten.compact.uniq.map do |name|
        name[0].match(/^(#|@)/) && name || "##{name}"
      end
    end

    def send_payload(payload)
      conn = Faraday.new(hook_url, { timeout: 5, open_timeout: 5 }) do |c|
        c.use(Faraday::Request::UrlEncoded)
        c.adapter(Faraday.default_adapter)
      end

      response = conn.post do |req|
        req.body = JSON.dump(payload)
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

    def valid_team_name?
      @team =~ /^[a-z\d\-]+$/ ? true : false
    end

    def hook_url
      "#{base_url}/services/hooks/incoming-webhook?token=#{@token}"
    end

    def base_url
      "https://#{@team}.slack.com"
    end
  end
end
