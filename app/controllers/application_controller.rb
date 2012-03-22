class ApplicationController < ActionController::Base
  protect_from_forgery
      
  before_filter :redis
  # before_filter :authenticate    
  
  def redis
    @redis ||= Redis.new(:host => "localhost", :port => 6379)
  end

  
  private
     def authenticate
        authenticate_or_request_with_http_basic do |id, password| 
            id == 'admin' && password == 'arunagw'
        end
     end  
end
