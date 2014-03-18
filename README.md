capistrano
==========

install
-------

```
cd /path/to/repository_root
bundle

# ruby >= 1.9  
# rbenv + .ruby_versionにて記載を想定 (現在は1.9.3-p545を記載)
```

deployコマンド
--------------

genius-src.tgzを配布、warビルド、serviceリスタートの実施 

- ad

```
bundle exec cap deploy production --roles=ad BUILD_ID=XXX

# サーバの増減に備えサーバ群は指定可能
# 例：
# bundle exec cap deploy production --roles=ad BUILD_ID=XXX ADS="`seq -f "ad%g.amoad.jp" 1 26`"

```

- imp

```
bundle exec cap deploy production --roles=imp BUILD_ID=XXX

# サーバの増減に備えサーバ群は指定可能
# 例：
# bundle exec cap deploy production --roles=ad BUILD_ID=XXX IMPS="`seq -f "imp%g" 3 14`"

```

todo
----

- ヘルスチェックapiの実装
- ステージングテスト(development -> staging)
- 本レポジトリの設置場所検討
