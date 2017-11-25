require 'watir'
watir = Watir::Browser.new(:firefox)

# TODO: [01: 北海道] のみ対応から各都道府県対応に変更する
# URL 中の数字が: たとえば [14: 神奈川] なので、数値を変えると動くのかもしれない
url = 'http://www.kaigokensaku.mhlw.go.jp/01/index.php?action_kouhyou_pref_search_list_list=true&PrefCd=01&OriPrefCd=01&method=pager&p_sort_name=47&p_order_name=1&p_count=5&p_offset=0iframe=1'

watir.goto(url)

watir.form(id: 'sel_ResultListForm').wait_until_present(5)

File.open('out.html', 'w') do |f|
  f.write watir.iframe(index: 0).div(id: 'searchResult').html
end

watir.close
