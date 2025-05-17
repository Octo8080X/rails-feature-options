# README

[システム開発・刷新のためのデータモデル大全 著：渡部幸三](https://www.njg.co.jp/book/9784534057778/)に書かれた、Feature Options の内容を実装するためのサンプル。

主に、`bundle exec rails test:test_task3` でテスト用rakeタスクを実行することで、動作確認できる。

# Usage
```bash

bundel install
bundel exec rails db:create
bundel exec rails db:migrate
bundel exec rails db:seed
bundle exec rails test:test_task3
```