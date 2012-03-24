class TweetsController < ApplicationController


  def index
    @tweets = (@redis.lrange(tweet_key, 0, -1).collect{|a| JSON.parse(a)}).paginate(:page => params[:page], :per_page => 15)
    @users = highscore_lb.leaders(1)
  end


  def create
    data = request.body.read
    
    if defined?(EmbedlyKey)
      embedly_api = Embedly::API.new(:key => EmbedlyKey)
    else
      embedly_api = Embedly::API.new
    end


    user = JSON.parse(data)["from_user"]
    user_id = JSON.parse(data)["from_user_id"]
    profile_image_url = JSON.parse(data)["profile_image_url"]
    _id = JSON.parse(data)["id"]

    objs = embedly_api.oembed(
        :url => "https://twitter.com/#!/#{user}/status/#{_id}",
        :wmode => 'transparent',
        :method => 'after'
    )
    obj = JSON.pretty_generate(objs[0].marshal_dump)

    @redis.lpush tweet_key, obj

    highscore_lb.change_score_for("#{user}:#{user_id}", 1)

    @redis.hmset("#{user}:#{user_id}",
                "profile_image_url", profile_image_url,
                "from_user", user)
    head :ok
  end


  def surprise
    
  end

  private

  def tweet_key
    @tweet_key ||= "tweets"
  end

  def users_key
    @users_key ||= "users"
  end

  def highscore_lb
    @highscore_lb ||= Leaderboard.new('highscores')
  end


end
