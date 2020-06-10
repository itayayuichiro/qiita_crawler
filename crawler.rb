require 'nokogiri'
require 'mechanize'

agent = Mechanize.new
login_page = agent.get("https://qiita.com/login")

doc = Nokogiri::HTML.parse(login_page.body, nil, 'utf-8')
token =  doc.css('.loginSessionsForm')[0].css('input')[0]['value']
agent.post("https://qiita.com/login",{
  identity: 'メールアドレス',
  password: 'パスワード',
  authenticity_token: token
})

page = agent.get("https://qiita.com/drafts/9854bdc1a4086754e4ab")
doc = Nokogiri::HTML.parse(page.body, nil, 'utf-8')
p doc