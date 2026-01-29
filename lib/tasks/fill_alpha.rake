namespace :data do
  desc "Fill data/sets/alpha.json using Scryfall API (overwrites file)."
  task fill_alpha: :environment do
    require 'net/http'
    require 'uri'
    require 'json'

    path = Rails.root.join('data','sets','alpha.json')
    backup = Rails.root.join('data','sets','alpha.json.bak.' + Time.now.strftime('%Y%m%d%H%M%S'))
    FileUtils.cp(path, backup)

    puts "Loaded #{path}, backup written to #{backup}"

    a = JSON.parse(File.read(path))

    total = a.length
    updated = 0
    missed = []

    user_agent = "deckbuilder-alpha-fill/1.0 (+https://github.com/your/repo)"

    a.each_with_index do |card, idx|
      name = card['name']
      found = nil

      # define helper
      get_json = lambda do |url|
        uri = URI(url)
        req = Net::HTTP::Get.new(uri)
        req['User-Agent'] = user_agent
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(req)
        end
        case res
        when Net::HTTPSuccess
          JSON.parse(res.body)
        when Net::HTTPTooManyRequests
          wait = (res['Retry-After'] || 5).to_i
          puts "Rate limited, waiting "+wait.to_s+"s"
          sleep wait
          JSON.parse(res.body) rescue nil
        else
          nil
        end
      rescue => e
        puts "HTTP error for #{url}: #{e.message}"
        nil
      end

      # Try searches in order
      # 1. exact with set
      q1 = "https://api.scryfall.com/cards/search?q=!\"#{URI.encode_www_form_component(name)}\"+set:lea"
      res1 = get_json.call(q1)
      if res1 && res1['data'] && res1['data'].any?
        found = res1['data'].first
      end

      # 2. exact without set
      if found.nil?
        q2 = "https://api.scryfall.com/cards/search?q=!\"#{URI.encode_www_form_component(name)}\""
        res2 = get_json.call(q2)
        if res2 && res2['data'] && res2['data'].any?
          found = res2['data'].first
        end
      end

      # 3. named fuzzy endpoint
      if found.nil?
        q3 = "https://api.scryfall.com/cards/named?fuzzy=#{URI.encode_www_form_component(name)}"
        res3 = get_json.call(q3)
        if res3 && res3['name']
          found = res3
        end
      end

      if found
        card['data'] = {
          'Type' => found['type_line'],
          'Mana Cost' => found['mana_cost'],
          'Color' => (found['colors'] && found['colors'].any?) ? found['colors'].join(',') : nil,
          'Rarity' => found['rarity'] && found['rarity'].capitalize,
          'Rules Text' => found['oracle_text'],
          'P/T' => (found['power'] && found['toughness']) ? "#{found['power']}/#{found['toughness']}" : nil,
          'Artist' => found['artist']
        }
        updated += 1
        puts "[#{idx+1}/#{total}] Found: #{name} -> #{found['name']}"
      else
        missed << name
        puts "[#{idx+1}/#{total}] Missed: #{name}"
      end

      sleep 0.12
    end

    File.write(path, JSON.pretty_generate(a))

    report = {
      total: total,
      updated: updated,
      missed_count: missed.length,
      missed: missed.take(200)
    }

    report_path = Rails.root.join('tmp','alpha_fill_report.json')
    File.write(report_path, JSON.pretty_generate(report))

    puts "Wrote updated file to #{path}. Report: #{report_path}"
    puts JSON.pretty_generate(report)
  end
end
