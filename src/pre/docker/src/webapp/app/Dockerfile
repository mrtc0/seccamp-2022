FROM rubylang/ruby:3.1.2-focal

WORKDIR /app

COPY Gemfile Gemfile 
COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY app.rb app.rb
COPY config.ru config.ru

ENTRYPOINT ["bundle", "exec", "rackup", "-o", "0.0.0.0", "config.ru"]
