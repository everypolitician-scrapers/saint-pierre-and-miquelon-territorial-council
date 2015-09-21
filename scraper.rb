#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[text()="Circonscription"]]//tr[td]').each do |tr|
    term = tr.xpath('preceding::h3/span[@class="mw-headline"]').last.text[/(\d+)/, 1]
    tds = tr.css('td')
    data = { 
      name: tds[0].text.tidy,
      wikiname: tds[0].xpath('.//a[not(@class="new")]/@title').text,
      party: tds[1].text.tidy,
      area: tds[2].text.tidy,
      term: term,
      source: url.to_s,
    }
    ScraperWiki.save_sqlite([:name, :area, :term], data)
  end
end

scrape_list('https://fr.wikipedia.org/wiki/Conseil_territorial_de_Saint-Pierre-et-Miquelon')
