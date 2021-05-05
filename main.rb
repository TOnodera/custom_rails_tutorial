require "erb"

html = File.read("index.html")

erb = ERB.new(html)

puts erb.result