require 'webrick'

# ↓この記述いれるとhtmlに埋め込まれた<%= %>とか<% %>のrubyスクリプトを処理してくれるみたい。 コメントアウトするとただhtml返すだけになる
WEBrick::HTTPServlet::FileHandler.add_handler('erb', WEBrick::HTTPServlet::ERBHandler)

# ./documentrootに置かれたファイルを実行して結果を返す
# 例えば <% val="test" %> <p><%= val%></p> を <p>test</p>にしてクライアント（ブラウザとか）に返す
server = WEBrick::HTTPServer.new({
                                   DocumentRoot: './documentroot/',
                                   BindAddress: '0.0.0.0',
                                   Port: 8000,
                                   MimeTypes: { 'erb' => 'text/html' }
                                 })
server.start

# この記述書いておけばサーバーとして起動してくれるみたい。
# 他にもやり方あるみたいだけど簡単そうだったからこれにしました。
# とりあえずこの記述入れておくとアクセスしたら./documentroot以下のファイルが返されるみたい

# htmlが返されるとブラウザ側でいろいろ処理してくれるよ。例えば、cssが必要だってhtmlに書いてあったらcssファイルをブラウザがサーバーにアクセスして持ってきて
# 最終的にきれいに描画される感じ。jsファイルも同じ
