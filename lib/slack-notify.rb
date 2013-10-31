require "slack-notify/version"
require "slack-notify/error"

require "json"
require "faraday"

module SlackNotify
  class Client
    def initialize(subdomain, token, options={})
      @subdomain = subdomain
      @token     = token
      @username  = options[:username] || "webhookbot"
      @channel   = options[:channel] || "general"

      raise ArgumentError, "Subdomain required" if @subdomain.nil?
      raise ArgumentError, "Token required"     if @token.nil?
    end

    def test
      send_payload(
        text: "This is a test message!",
        channel: @channel,
        username: @username
      )
    end

    def notify(text, channel=nil)
      send_payload(
        text: text,
        channel: channel || @channel,
        username: @username
      )
    end

    private

    def send_payload(payload)
      response = Faraday.post(url, token: @token) do |req|
        req.body = JSON.dump(payload)
      end

      if response.success?
        true
      else
        raise SlackNotify::Error.new(response.body)
      end
    end

    def url
      "https://#{@subdomain}.slack.com/services/hooks/incoming-webhook"
    end
  end
end