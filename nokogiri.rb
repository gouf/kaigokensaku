require 'nokogiri'
require 'pp'

file = File.read('out.html') # watir.rb 実行後に生成されるものを利用する
doc = Nokogiri::HTML(file)

# TODO: refactor the code
doc.xpath('//ul/li[contains(@class, "listLi")]').size.times do |i|
  # ホームページ(無い場合もある, メールアドレスの場合もある)
  onclick =
    doc.xpath(%(//ul/li[#{i + 1}]//li[contains(@class, "homepageIcon")]/a[@onclick][1]))&.attribute('onclick') rescue ''
  p home_page = %r{\('([^']+)}.match(onclick)&.captures&.first || ''

  p doc.xpath(%(//ul/li[#{i + 1}]//li/span[contains(@class, "listService")])).text # 施設タイプ
  p doc.xpath(%(//ul/li[#{i + 1}]//a[contains(@class, "noLink")])).text # 施設名称
  p doc.xpath(%(//ul/li[#{i + 1}]//li[contains(@class, "yoboIcon")]/img)).attribute('alt').value # 「予防」有無
  # 営業日
  business_day =
    doc.xpath(%(//ul/li[#{i + 1}]//li[contains(@class, "openIcon")]/img)).map do |img|
      src = img.attribute('src').value
      day =
        %w[weekday saturday sunday holiday].each_with_index do |elm, i|
          break %w[平日 土曜 日曜 祝日][i] if src.match?(elm)
        end
      day + (src.match?('_off') ? '休業' : '営業')
    end
  p business_day
  # 公表年度, 公表日, 事業所番号
  sub_data =
    doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "listSubData")]/table/tbody/tr/td[1])).map(&:text)
  p %w[公表年度 公表日 事業所番号].zip(sub_data).map { |x| x.join(' ') }
  # 所在地
  p doc.xpath(%(//ul/li[#{i + 1}]//span[contains(@class, "postalCode")])).text # 郵便番号
  p doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "listAddress")])).text.strip.split("\n").last.strip # 住所

  # 地図URL(Google Map)
  onclick =
    doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "listAddress")]/a[contains(@class, "btnMapOpen")][@onclick]))
      &.attribute('onclick')
      .value
  p map = %r{\('([^']+)}.match(onclick)&.captures&.first || ''

  # 電話番号2種類
  phone, _br, fax = doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "tel")])).children
  p %w[電話番号 FAX番号].zip([phone, fax].map(&:text))
  p '空き情報の更新日：' + doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "sortCont")])).text.strip # 空き情報の更新日
  p 'サービス提供地域：' + doc.xpath(%(//ul/li[#{i + 1}]//td[contains(@class, "listServiceArea")])).text
  puts ''
end
# =>
# "http://kigyou.net/asagao946"
# "小規模多機能型"
# "小規模多機能ホームあさがお"
# "予防あり"
# ["平日休業", "土曜休業", "日曜休業", "祝日休業"]
# ["公表年度 平成27年度", "公表日 2016年3月30日", "事業所番号 0194100269"]
# "〒085-0811"
# "釧路市興津2丁目29番44号"
# "http://maps.google.co.jp/maps?q=42.961125000000000,144.410928099999980&hl=ja"
# [["電話番号", "0154-64-5475"], ["FAX番号", "0154-64-5476"]]
# "空き情報の更新日：2017年11月25日"
# "サービス提供地域：釧路市東部南地区"
