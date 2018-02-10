require 'sinatra'
require 'sinatra/reloader'
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def render_markdown(content)
  Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(content)
end

def load_file_content(file_path)
  content = File.read(file_path)

  if File.extname(file_path) == '.md'
    headers["Content-Type"] = "text/html"
    erb render_markdown(content)
  else # TODO: this allows to create files with any (or no) extension
    headers["Content-Type"] = "text/plain"
    content
  end
end

before do
  pattern = File.join(data_path, '*')
  @files = Dir.glob(pattern).map { |path| File.basename(path) }
end

get '/' do
  erb :index
end

get '/:filename' do
  filename = params[:filename]
  file_path = File.join(data_path, params[:filename])

  if @files.include?(filename)
    load_file_content(file_path)
  else
    session[:message] = 'The requested file does not exist.'
    redirect('/')
  end
end

get '/:filename/edit' do
  @filename = params[:filename]
  file_path = File.join(data_path, params[:filename])

  if @files.include?(@filename)
    @content = File.read(file_path)
    erb(:edit_file)
  else
    session[:message] = 'The requested file does not exist.'
    redirect('/')
  end
end

post '/:filename' do
  filename = params[:filename]
  file_path = File.join(data_path, filename)

  content = params[:content]
  File.write(file_path, content)
  session[:message] = 'The file has been modified.'
  redirect "/"
end

get '/document/new' do
  erb(:new_document)
end

post '/document/new' do
  filename = params[:filename]

  if filename != ''
    file_path = File.join(data_path, filename)
    File.new(file_path, 'w')
    session[:message] = "The file '#{filename}' has been created."
    redirect '/'
  else
    session[:message] = "Enter at least one non-whitespace character."
    status 422
    erb(:new_document)
  end
end
