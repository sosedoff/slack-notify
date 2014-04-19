# slack-notify

Send notifications to [Slack](http://slack.com/)

[![Build Status](https://travis-ci.org/sosedoff/slack-notify.png?branch=master)](https://travis-ci.org/sosedoff/slack-notify)
[![Code Climate](https://codeclimate.com/github/sosedoff/slack-notify.png)](https://codeclimate.com/github/sosedoff/slack-notify)

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
client = SlackNotify::Client.new("team", "token")
```

Initialize with options:

```ruby
client = SlackNotify::Client.new("team", "token", {
  channel: "#development",
  username: "mybot",
  icon_url: "http://mydomain.com/myimage.png",
  icon_emoji: ":shipit:"
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

## Gotchas

Current issues with Slack API:

- No message raised if team subdomain is invalid
- 500 server error is raised on bad requests

## License

Copyright (c) 2013-2014 Dan Sosedoff, <dan.sosedoff@gmail.com>

MIT License