# SeedBuilder

絶賛開発中です🙏

## 使い方

```
SeedBuilder::Core.new.processing
```

## 開発のやり方（gemのみ）

### pryの起動

```
./bin/console
```

基本的にはpryの中でデバッグしながら開発をします。

### テストモデルの設定

- spec/support/setup_database.rb
- spec/support/setup_model.rb

`setup_database.rb` でスキーマ定義、 `setup_model.rb` でモデルクラス定義をします。

### 知ってると得するメソッド

```
Blog.create

blog = Blog.new
blog.attribute_collection
blog.attribute_collection.title
blog.attribute_collection.title.build
```

## 開発のやり方（Railsと一緒に）

新規でダミーのRailsプロジェクトを作ります。

```
$ cd ~/projects
$ docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/app -w /app rails:5.1 rails new --skip-bundle seed_builder_rails_sample
$ cd seed_builder_rails_sample
$ touch Dockerfile
```

### Dockerfile

```
FROM rails:5

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 9292
```

```
docker build -t seed_builder_rails_sample .
docker run --rm -it -d -w /app -v "$PWD:/app" -v "/<PATH>/seed_builder:/seed_builder" -p 9292:9292 seed_builder_rails_sample
```

ポイントはgem `seed_builder` のディレクトリをボリュームマウントする所です。これによって、gemのソースコードを修正したものをそのままRailsプロジェクトに反映させられます。

### Gemfile

```
gem 'seed_builder', path: '/seed_builder'
```

これで一度 `bundle install` すれば、リアルタイムでgemソースの変更が反映されます。

EXPOSE 9292
EXPOSE 9292
