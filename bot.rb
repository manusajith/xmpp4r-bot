require 'xmpp4r'
require 'xmpp4r/client'
require 'xmpp4r/roster'
require 'rss'
require 'open-uri'
include Jabber

class Bot

  attr_reader :client

  def initialize jabber_id
    @jabber_id = jabber_id
    @jabber_password = ENV['jabber_password']
  end

  def connect
    jid = JID.new(@jabber_id)
    @client = Client.new jid
    @client.connect
    @client.auth @jabber_password
    @client.send(Presence.new.set_type(:available))
    puts "Hurray...!!  Connected..!!"
    on_message
  end

  private
  def on_message
    mainthread = Thread.current
    @client.add_message_callback do |message|
      unless message.body.nil? && message.type != :error
        reply = case message.body
          when "Time" then reply(message, "Current time is #{Time.now}")
          when "Help" then reply(message, "Available commands are: 'Time', 'Help'.")
          when "Latest sitepoint articles" then latest_sitepoint_articles(message)
          else reply(message, "You said: #{message.body}")
        end
      end
    end
    Thread.stop
    @client.close
  end

  def reply message, reply_content
    reply_message = Message.new(message.from, reply_content)
    reply_message.type = message.type
    @client.send reply_message
  end

  def latest_sitepoint_articles message
    feeds = SitepointFeedParser.get_feeds
    feeds.items.each do |item|
      reply(message, item.link)
    end
  end

end

class SitepointFeedParser

  URL = 'http://www.sitepoint.com/feed/'
  class << self
    def get_feeds
      open(URL) do |rss|
        @feeds = RSS::Parser.parse(rss)
      end
      @feeds
    end
  end

end

@bot = Bot.new 'manusajith@gmail.com'
@bot.connect