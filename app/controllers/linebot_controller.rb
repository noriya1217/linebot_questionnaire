class LinebotController < ApplicationController
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # アンケートという文字列を受信したら、メソッドtemplate_q1を呼び出す
          if event.message['text'].eql?('アンケート')
            client.reply_message(event['replyToken'], template_q1)

          # Q1.○○○…という文字列を受信したら、メソッドtemplate_q2を呼び出す
          elsif event.message['text'].start_with?("Q1.")
            client.reply_message(event['replyToken'], template_q2)

          # Q2.○○○…という文字列を受信したら、メソッドtemplate_q3を呼び出す
          elsif event.message['text'].start_with?("Q2.")
            client.reply_message(event['replyToken'], template_q3)

          end
        end
      end
    }

    head :ok
  end

  private

  def template_q1
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "Q1.今日のもくもく会は楽しいですか？",
          "actions": [
              {
                "type": "message",
                "label": "楽しい",
                "text": "Q1.楽しい"
              },
              {
                "type": "message",
                "label": "楽しくない",
                "text": "Q1.楽しくない"
              }
          ]
      }
    }
  end

  def template_q2
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "Q2.このQiita記事は参考になりましたか？",
          "actions": [
              {
                "type": "message",
                "label": "はい",
                "text": "Q2.はい"
              },
              {
                "type": "message",
                "label": "いいえ",
                "text": "Q2.いいえ"
              }
          ]
      }
    }
  end

  def template_q3
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "Q3.他のAPIを使ったLINE Botを作りたいですか？",
          "actions": [
              {
                "type": "message",
                "label": "はい",
                "text": "Q3.はい"
              },
              {
                "type": "message",
                "label": "いいえ",
                "text": "Q3.いいえ"
              }
          ]
      }
    }
  end
end