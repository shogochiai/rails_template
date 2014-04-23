rails_template.rb
=================

rails4で個人開発の初速を上げるためのapplication template

```

rails_new () {
  rails new $* -T -m rails_template/rails_template.rb -d=mysql --skip-bundle
}

```

このシェルスクリプトを利用します

