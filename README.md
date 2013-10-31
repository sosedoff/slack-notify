# slack-notify

Send notifications to [Slack](http://slack.com/)

## Installation

Add this line to your application's Gemfile:

```
gem "slack-notify"
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install slack-notify
```

## Usage

Require:

```ruby
require "slack-notify"
```

Initialize client:

```ruby
client = SlackNotify::Client.new("subdomain", "token")
```

Initialize with options:

```ruby
client = SlackNotify::Client.new("subdomain", "token", {
  channel: "#development",
  username: "mybot"
})
```

Send test request:

```ruby
client.test
```

Send message:

```ruby
client.notify("Hello There!")
client.notify("Another message", "#channel2")
```
