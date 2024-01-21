require 'nokogiri'
require 'httparty'
require 'uri'
require 'sequel'

$AMAZON_DOMAIN = 'https://www.amazon.pl'
$START_URL = 'https://www.amazon.pl/b?node=20788267031&pf_rd_r=2NYJY05XYZMTJ49F41NF'
$KEYWORD = "iPhone"

DB = Sequel.sqlite(':memory:')

DB.create_table? :products do
  primary_key :id
  column :title, String
  column :price, String
  column :os, String
  column :mem, String
  column :address, String
end

$products = DB[:products]

class Product < Sequel::Model
end

def crawl(url, depth = 2, visited = Set.new)
  return if depth.zero? || visited.include?(url)

  visited.add(url)

  headers = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Referrer' => 'strict-origin-when-cross-origin'
  }

  response = HTTParty.get(url, headers: headers)
  if response.body.nil? || response.body.empty?
    puts "Response body is empty."
  else
    doc = Nokogiri::HTML(response)

    if depth == 2
      doc.xpath('//a[@class="a-link-normal octopus-pc-item-link"]', '//a[@class="a-link-normal s-no-outline"]').each do |link|
        href = link['href']
        next if href.nil? || href.empty?

        absolute_url = URI.join($AMAZON_DOMAIN, href).to_s
        sleep(0.25)
        crawl(absolute_url, depth - 1, visited)
      end
    else
      title_elements = doc.xpath('//span[@id="productTitle"]').map { |title| title.text.strip }
      price_elements = doc.xpath('//span[@class="aok-offscreen"]').map { |price| price.text.strip }
      os_elements = doc.xpath('//tr[@class="a-spacing-small po-operating_system"]//td//span[@class="a-size-base po-break-word"]').map { |os| os.text.strip }
      mem_elements = doc.xpath('//tr[@class="a-spacing-small po-memory_storage_capacity"]//td//span[@class="a-size-base po-break-word"]').map { |mem| mem.text.strip }

      pattern = /#{$KEYWORD}/i
      if title_elements.size == 1 && title_elements[0].match?(pattern) && $KEYWORD != ""
        title = title_elements[0]
        price = price_elements[0]
        os = os_elements[0]
        mem = mem_elements[0]
        address = url

        $products.insert(title: title, price: price, os: os, mem: mem, address: address)
      elsif title_elements.size == 1 && $KEYWORD == ""
        title = title_elements[0]
        price = price_elements[0]
        os = os_elements[0]
        mem = mem_elements[0]
        address = url

        $products.insert(title: title, price: price, os: os, mem: mem, address: address)
      end
    end
  end
end

crawl($START_URL)

$products = DB.from(:products)
$products.all
$products.each{|row| p row}

DB.disconnect
