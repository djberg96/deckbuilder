#!/usr/bin/env ruby
require 'json'
path = File.join(__dir__, '..', 'data', 'sets', 'alpha.json')
out = File.join(__dir__, '..', 'tmp', 'alpha_fill_report.json')
js = JSON.parse(File.read(path))
 total = js.length
filled = js.count{|c| c['data'].values.any?{|v| !v.nil?}}
empty = js.count{|c| c['data'].values.all?{|v| v.nil?}}
misses = js.select{|c| c['data'].values.all?{|v| v.nil?}}.map{|c| c['name']}
report = { total: total, filled: filled, empty: empty, sample_missed: misses.first(50) }
File.write(out, JSON.pretty_generate(report))
puts "Wrote report to #{out}"
