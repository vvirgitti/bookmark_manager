require 'sinatra/base'
require 'data_mapper'

class Bookmark < Sinatra::Base

  env = ENV['RACK_ENV'] || 'development'

  set :views, Proc.new {File.join(root, "..", "views")}

  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

  require './lib/link'

  DataMapper.finalize
  DataMapper.auto_upgrade!

  get '/' do
    'Hello Bookmark!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
