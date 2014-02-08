require "slack-notify/version"
require "slack-notify/error"

require "json"
require "faraday"

module SlackNotify
  class Client
    def initialize(team, token, options={})
      @team     = team
      @token    = token
      @username = options[:username] || "webhookbot"
      @channel  = options[:channel]  || "#general"

      raise ArgumentError, "Team name required" if @team.nil?
      raise ArgumentError, "Token required"     if @token.nil?
    end

    def test
      notify("This is a test message!")
    end

    def notify(text, channel=nil)
      channels = [channel || @channel].flatten.compact.uniq

      channels.each do |chan|
        chan.prepend("#") if chan[0] != "#"
        send_payload(text: text, username: @username, channel: chan)
      end

      true
    end

    private

    def send_payload(payload)
      conn = Faraday.new(hook_url, { timeout: 5, open_timeout: 5 }) do |c|
        c.use(Faraday::Request::UrlEncoded)
        c.adapter(Faraday.default_adapter)
      end

      response = conn.post do |req|
        req.body = JSON.dump(payload)
      end

      if response.success?
        true
      else
        if response.body.include?("\n")
          raise SlackNotify::Error
        else
          raise SlackNotify::Error.new(response.body)
        end
      end
    end

    def hook_url
      "https://#{@team}.slack.com/services/hooks/incoming-webhook?token=#{@token}"
    end
  end
end