require 'json'

RSpec.describe 'data/sets/alpha.json' do
  it 'contains the 295 Alpha card names' do
    path = File.expand_path('data/sets/alpha.json', Dir.pwd)
    names = JSON.parse(File.read(path))

    expect(names).to be_an(Array)
    expect(names.length).to eq(290)

    # spot-check some canonical cards
    expect(names).to include('Ancestral Recall')
    expect(names).to include('Time Walk')
    expect(names).to include('Black Lotus')
    expect(names).to include('Serra Angel')
    expect(names).to include('Mox Sapphire')

    # no duplicates
    expect(names.length).to eq(names.uniq.length)
  end
end
