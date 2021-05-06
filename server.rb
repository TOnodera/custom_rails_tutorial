require 'erb'
require 'webrick'
require 'sqlite3' # データベース接続用オブジェクト

# この記述書いておけばサーバーとして起動してくれるみたい。railsはこのWEBrickっていうの組み込んでる？？
# もっと低レベル（生に近い）やり方あるみたいだけど、参考資料あんまりなかったからこのやり方にしました。
# htmlが返されるとブラウザ側でいろいろ処理してくれるよ。例えば、cssが必要だってhtmlに書いてあったらcssファイルをブラウザがサーバーにアクセスして持ってきて
# 最終的にきれいに描画される感じ。jsファイルも同じ

server = WEBrick::HTTPServer.new({
                                   BindAddress: '0.0.0.0',
                                   Port: 8000,
                                   MimeTypes: { 'erb' => 'text/html' }
                                 })

def open_database
  # データベース設定
  database = SQLite3::Database.new('tutorial')
  # テーブルがなければ作成
  database.execute('CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,email VARCHAR(255) NOT NULL)')

  database
end

# /(ドキュメントルート)来たときの処理
server.mount_proc '/' do |_req, _res|
  database = open_database
  # 登録処理と表示を全部このなかでやってみる（後でクラスわけまーす）
  html = File.open('./erb/index.html.erb').read
  erb = ERB.new(html)

  # POSTでoperationの値がinsertだったら新規登録処理
  operation = _req.query['operation']
  if _req.request_method == 'POST'

    if operation == 'create'
      # ここでフォームから送られた値を取得する
      name = _req.query['name']
      email = _req.query['email']

      # メールアドレス用のバリデーション必要なら入れる(こんなのあんだーくらいに思っておけば大丈夫　コピペ)
      # mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

      if name.empty? == false && email.empty? == false # && email.match?(mailRegex)
        database.execute('INSERT INTO users (name,email) VALUES(?,?)', name, email)
      end
    end

    if operation == 'edit'

      # ここでフォームから送られた値を取得する
      id = _req.query['id'].to_i

      # idに一致するデータがあるかチェック
      row = database.execute('SELECT * FROM users WHERE id = ?', id)
      name = _req.query['name']
      email = _req.query['email']
      # idに一致するデータがあるかチェック
      if name.empty? == false && email.empty? == false && (row.size > 0) # && email.match?(mailRegex)
        database.execute('UPDATE users SET name = ?,email = ? WHERE id = ?', name, email, id)
      end

      puts row
      # database.execute('DELETE FROM users WHERE id = ?', id) if row.size > 0

    end

    if operation == 'delete'

      # ここでフォームから送られた値を取得する
      id = _req.query['id'].to_i

      # idに一致するデータがあるかチェック
      row = database.execute('SELECT * FROM users WHERE id = ?', id)
      database.execute('DELETE FROM users WHERE id = ?', id) if row.size > 0

    end

  end

  # データベースに登録済データあれば取得
  rows = []
  database.execute('SELECT * FROM users').each do |row|
    user = { 'id' => row[0], 'name' => row[1], 'email' => row[2] }
    rows.push(user)
  end

  _res.status = 200
  _res['Content-Type'] = 'text/html'
  _res.body = erb.result_with_hash({ rows: rows })

  database.close
end

# editor.html.erb来たときの処理
server.mount_proc '/editor' do |_req, _res|
  database = open_database
  html = File.open('./erb/editor.html.erb').read
  erb = ERB.new(html)
  id = _req.query['id'].to_i

  # id無かったら/にリダイレクト
  _res.set_redirect WEBrick::HTTPStatus::TemporaryRedirect, '/' if id.to_s.nil? || id.to_s.empty? || id.zero?

  row = database.execute('SELECT * FROM users WHERE id = ? ', id)

  _res.status = 200
  _res['Content-Type'] = 'text/html'
  _res.body = erb.result_with_hash({ row: { 'id' => row[0][0], 'name' => row[0][1],
                                            'email' => row[0][2] } })

  database.close
end

server.start
