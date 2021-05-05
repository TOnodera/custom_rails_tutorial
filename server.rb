require 'webrick'

server = WEBrick::HTTPServer.new({ 
	:DocumentRoot => './documentroot/',
	:BindAddress => 'localhost',
	:Port => 8000
})
server.start

#この記述書いておけばサーバーとして起動してくれるみたい。
#このやり方以外だとApacheサーバーと連携したりとかあるみたいだけど設定増えて意味わかんなくなりそうだから辞めました。
#とりあえずこの記述入れておくとアクセスしたら./documentroot以下のEファイルが実行されるって覚えれば良さそう。