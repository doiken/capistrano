capistrano
==========

install
-------

ruby >= 1.9
rbenv + .ruby_versionにて記載を想定
(現在は1.9.3-p545を記載)

```
cd /path/to/repository_root
bundle
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

buildコマンド
-------------

/path/to/current/deliverディレクトリ下のwarビルド、serviceリスタートの実施 

- ad

```
bundle exec cap deploy production --roles=ad BUILD_ID=XXX
```

- imp

```
bundle exec cap deploy production --roles=imp BUILD_ID=XXX
```

rollbackコマンド
----------------

直前のリリースに切り替え、serviceリスタートの実施
※ 指定巻き戻しはBUILD_ID再指定による際deployを想定

- ad

```
bundle exec cap deploy:rollback production --roles=ad
```

- imp

```
bundle exec cap deploy:rollback production --roles=imp
```

todo
----

- ヘルスチェックapiの実装
- 分割リリース方式の検討
- ステージングテスト(development -> staging)
- 本レポジトリの設置場所検討
