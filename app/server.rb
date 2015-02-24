require 'sinatra/base'
require 'data_mapper'

class BookmarkManager < Sinatra::Base

  env = ENV['RACK_ENV'] || 'development'

  set :views, Proc.new {File.join(root, "..", "views")}

  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

  require_relative './lib/link'

  DataMapper.finalize
  DataMapper.auto_upgrade!

  get '/' do
    @links = Link.all
    @links.each do |link|
    end
    erb :index
  end



  # start the server if ruby file executed directly
  run! if app_file == $0
end
