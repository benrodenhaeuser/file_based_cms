require 'sinatra'
require 'sinatra/reloader'
require "sinatra/content_for"
require "tilt/erubis"


get "/" do
  "Hello world!"
end
