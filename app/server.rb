require 'sinatra/base'
require 'data_mapper'
require 'rack-flash'

class BookmarkManager < Sinatra::Base

  env = ENV['RACK_ENV'] || 'development'

  enable :sessions
  use Rack::Flash
  set :session_secret, 'super secret'

  set :views, Proc.new {File.join(root, "..", "views")}

  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

  require_relative './lib/link'
  require_relative './lib/tag'
  require_relative './lib/user'


  DataMapper.finalize
  DataMapper.auto_upgrade!


  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(' ').map do |tag|
      Tag.first_or_create(text: tag)
    end
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:tag' do
    tag = Tag.first_or_create(text: params[:tag])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :"users/new"
  end

  post '/users' do
    @user = User.create(:email => params[:email],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash[:notice] = "Sorry, your passwords don't match"
      erb :"users/new"
    end
  end

  helpers do
    def current_user
      @current_user ||=User.get(session[:user_id]) if session[:user_id]
    end
  end



  # start the server if ruby file executed directly
  run! if app_file == $0
end
