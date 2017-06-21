# SeedBuilder

絶賛開発中です🙏

## 使い方

```
SeedBuilder::Core.new.processing
```

今はオブジェクトが作られるだけで実際に保存はされません。

## 開発のやり方

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

