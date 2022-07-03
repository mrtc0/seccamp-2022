require 'sinatra/base'

class HelloApp < Sinatra::Base
  get '/' do
    'Hello Sinatra'
  end
end
