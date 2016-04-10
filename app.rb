require 'bundler/setup'
require 'sinatra'
require 'json'
require 'rest-client'

post '/linebot/callback' do
  params = JSON.parse(request.body.read)

  params['result'].each do |msg|
    text = msg['content']['text']
    trigger_words = ENV["REPLY_WORDS"].split(",")
    next if !trigger_words.any{|w| text.match(/#{Regexp.escape(w)}/)}

    request_content = {
      to: [msg['content']['from']],
      toChannel: 1383378250, # Fixed  value
      eventType: "138311608800106203", # Fixed value
      content: {
        "contentType": 1,
        "toType": 1,
        "text": ENV["REPLY_WORDS"].split(",").sample
      }
    }

    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    content_json = request_content.to_json

    RestClient.proxy = ENV["FIXIE_URL"]
    RestClient.post(endpoint_uri, content_json, {
      'Content-Type' => 'application/json; charset=UTF-8',
      'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
      'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
      'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
    })
  end

  "OK"
end
