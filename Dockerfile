FROM ruby:3.0.1 AS reactive-chess-dev

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install --no-install-recommends -y nano nodejs yarn

ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

RUN chown -R user:user $INSTALL_PATH
RUN chmod -R 777 /usr/local/bundle

WORKDIR $INSTALL_PATH
COPY reactive-chess/ .

RUN rm -rf node_modules vendor
RUN gem install rails bundler
RUN bundle install
RUN yarn install
RUN rails webpacker:install
RUN chown -R user:user /opt/app


USER $USER_ID
CMD rails s