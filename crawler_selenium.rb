require 'nokogiri'
require 'mechanize'
require 'selenium-webdriver'

def selemium_init
  ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36'
  # caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { args: ["--user-agent=#{ua}", 'window-size=1280x800', '--incognito'] }) # シークレットモード
  caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => {args: ["--headless","--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu", "--user-agent=#{ua}", 'window-size=1280x800']})
  
  client = Selenium::WebDriver::Remote::Http::Default.new
  driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps  
end

driver = selemium_init
driver.navigate.to 'https://qiita.com/login'
driver.execute_script("document.getElementsByName('identity')[0].value = 'メールアドレス'")
driver.execute_script("document.getElementsByName('password')[0].value = 'パスワード'")
driver.execute_script("document.getElementsByName('commit')[0].click()")
sleep 1
driver.navigate.to 'https://qiita.com/drafts'

doc = Nokogiri::HTML.parse(driver.page_source, nil, 'utf-8')
json = JSON.parse(doc.css('.js-react-on-rails-component')[1].inner_html)
json['creating_draft_items'].each do |item|
  if item['raw_body'].match(/予約投稿/)
    date = item['raw_body'].split('予約投稿:')[1]
    # 予約投稿予定日のものがあったら
    if Date.today == Date.parse(date)
      driver.navigate.to "https://qiita.com/drafts/#{item['item_uuid']}/edit?resume=true"
      element = driver.find_element(:class, 'editorSubmit_dropdownToggle')
      element.click
      element = driver.find_elements(:class,'editorSubmit_dropdownItem')[2]
      element.click
      submit_element = driver.find_element(:class,'editorSubmit_submitBtn')
      submit_element.click
      label_element = driver.find_element(:class,'creatingModal_label')
      label_element.click
      button_element = driver.find_elements(:class,'btn-primary')[-1]
      button_element.click
      sleep 3
    end
  end
end