[構築手順]
1. GitHub上に保存されているRails Projectにアクセスする。本件の場合下記URLにアクセスする。
https://github.com/ihatov08/rails7_docker_template
2. `Use this template`ボタンを押下し、プルダウンより 'Create a new repository'を選択する。
3. 新規リポジトリ作成画面で、 Repository nameを入力し(例： `rails-docker`)、`Create repository`ボタンを押下しGitHub上にリポジトリを作成する。(その他の項目はデフォルトでOK。)
4. 自分のGitHub上にリポジトリが作られる。遷移先画面にて`<> Code`ボタンを押下、SSH欄の`git@github.com:<YOUR ACCOUNT>/rails-docker.git`をコピーしておく。（必要に応じてメモ帳にペーストしておく）
5. ホスト(自分のPC)にてターミナルを起動。任意のディレクトリにて下記コマンドを入力する。リモートリポジトリ上のRails Project一式がホストにコピーされる。
`git clone `git@github.com:<YOUR ACCOUNT>/rails-docker.git` 
6. rails-dockerディレクトリが作成されるので、cdコマンドにて移動する。
`cd rails-docker`
7. docker化するにあたり、まずはdockerブランチを作成する。
`git checkout -b docker`
8. Dockerfileを以下の内容で作成します。
touch Dockerfile

```Dockerfile

FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /rails-docker

WORKDIR /rails-docker

ADD Gemfile Gemfile.lock /rails-docker/

RUN gem install bundler
RUN bundle install

ADD . /rails-docker

```

:::note 
Dockerfileの中身は、 `vim Dockerfile`等でファイルを開き、上記の内容通りに記入します。以下テキストファイルの作成手順は同様です。(vimの使い方やその他テキストファイルの作成・保存方法の記述は割愛します。)
:::

9. docker-compose.ymlを以下の内容で作成します。
touch docker-compose.yml

```docker-compose.yml

version: '3'

services:
  db:
    container_name: rails-docker-db
    image: postgres:12
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgresql-data:/var/lib/postgresql/data
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/rails-docker
    ports:
      - "3000:3000"
    depends_on:
      - db
      
volumes:
  postgresql-data:
    driver: local

```

:::note 
- データベースはpostgresql12を使用しています。
- postgresqlのパスワードは"postgres"と直書きしています。開発用環境構築目的ではこれでも大きな問題となりませんが、本番環境で運用する際は、セキュリティに配慮した実装にしてください。
:::


10. database.ymlファイルを編集する。(default: &defaultの部分を下記のように変更します。)

:::note
- database.ymlファイルは、rails-docker > config ディレクトリ配下にあります。
:::

- 変更前
```database.yml

default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

```

- 変更後
```database.yml

default: &default
  adapter: postgresql
  encoding: unicode
  host: db
  username: postgres
  password: postgres
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

```
:::note
- database.ymlのコメント部分は記述を割愛しています。
:::

11. Dockerイメージを作成する。
`docker-compose build`

12. コンテナの作成し、バッググラウンドで起動する。
`docker-compose up -d`

13. Webコンテナにログインし、データベースの作成を行う。
`docker-compose run web rails db:create`

14. データベースのマイクレーションを行う
`docker-compose run web rails db:migrate`

15. コンテナの起動状態を確認する。
`docker-compose ps`

16. ホストにてブラウザ(Chrome)を起動し、下記に接続する。
http://localhost:3000 
