require 'rails_helper'

RSpec.describe 'Cards index pagination', type: :request do
  it 'paginates cards and respects per_page selection' do
    user = User.create!(username: 'pager', password: 'password123')
    post login_path, params: { username: 'pager', password: 'password123' }
    follow_redirect!

    game = Game.create!(name: 'PgTest', edition: 'E')
    # create 60 cards
    60.times do |i|
      Card.create!(name: "Card #{i}", game: game)
    end

    get cards_path, params: { per_page: 10 }
    expect(response.body).to include('Showing <strong>1–10</strong> of <strong>60</strong>')
    # ensure only 10 rows are rendered (count table rows)
    doc = Nokogiri::HTML(response.body)
    rows = doc.css('table tbody tr')
    expect(rows.count).to eq(10)

    # go to page 3
    get cards_path, params: { per_page: 10, page: 3 }
    expect(response.body).to include('Showing <strong>21–30</strong> of <strong>60</strong>')

    # change per_page to 25
    get cards_path, params: { per_page: 25 }
    expect(response.body).to include('Showing <strong>1–25</strong> of <strong>60</strong>')
    doc = Nokogiri::HTML(response.body)
    expect(doc.css('table tbody tr').count).to eq(25)
  end
end
