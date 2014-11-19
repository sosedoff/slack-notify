# slack-notify

Send notifications to [Slack](http://slack.com/) via webhooks.

[![Build Status](http://img.shields.io/travis/sosedoff/slack-notify/master.svg?style=flat)](https://travis-ci.org/sosedoff/slack-notify)
[![Code Climate](http://img.shields.io/codeclimate/github/sosedoff/slack-notify.svg?style=flat)](https://codeclimate.com/github/sosedoff/slack-notify)
[![Gem Version](http://img.shields.io/gem/v/slack-notify.svg?style=flat)](http://rubygems.org/gems/slack-notify)

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
client = SlackNotify::Client.new(webhook_url: "slack webhook url")
```

Initialize with options:

```ruby
client = SlackNotify::Client.new(
  webhook_url: "slack webhook url",
  channel: "#development",
  username: "mybot",
  icon_url: "http://mydomain.com/myimage.png",
  icon_emoji: ":shipit:",
  link_names: 1
)
```

Initialize via shorthand method:

```ruby
client = SlackNotify.new(options)
```

Send test request:

```ruby
client.test
```

Send message:

```ruby
client.notify("Hello There!")
client.notify("Another message", "#channel2")
client.notify("Message", ["#channel1", "#channel2"])
```

Send direct message:

```ruby
client.notify("Hello There!", "@username")
```

You can also test gem via rake console:

```
rake console
```

## License

Copyright (c) 2013-2014 Dan Sosedoff, <dan.sosedoff@gmail.com>

MIT License