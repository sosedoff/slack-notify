require "slack-notify/version"
require "slack-notify/error"
require "slack-notify/connection"
require "slack-notify/payload"
require "slack-notify/client"

module SlackNotify
  def self.new(options = {})
    SlackNotify::Client.new(options)
  end
end