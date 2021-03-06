require 'sinatra/base'
require 'data_mapper'
require 'rack-flash'

class BookmarkManager < Sinatra::Base

  env = ENV['RACK_ENV'] || 'development'

  enable :sessions
  use Rack::Flash
  use Rack::MethodOverride

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
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end


  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The email or password is incorrect"]
      erb :"sessions/new"
    end
  end

  delete '/sessions' do
    flash[:notice] = "Goodbye!"
    session[:user_id] = nil
    redirect to('/')
  end


  get '/passwords/new' do
    erb :"passwords/new"
  end


  post '/passwords' do
    @user = User.new
    flash[:notice] = "An email was just sent to you"
    erb :"users/new"
  end

  helpers do
      def current_user
        @current_user ||=User.get(session[:user_id]) if session[:user_id]
      end

      # def check_user
      #   # User.get(1).email
      #   user = first(:email => email)
      #   user.include?(:email)
      # end






  # start the server if ruby file executed directly
  run! if app_file == $0
end
