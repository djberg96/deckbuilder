require 'rails_helper'

RSpec.describe 'Cards import (skip invalid rows)', type: :request do
  it 'imports valid rows and reports failures for invalid ones' do
    user = User.create!(username: 'importer', password: 'password123')
    post login_path, params: { username: 'importer', password: 'password123' }
    follow_redirect!

    valid = { name: 'ImportGood', description: 'ok', data: { 'type' => 'Creature' } }
    invalid = { name: 'ImportBad', data: { 'Has-Hyphen' => 'x' } }
    json = [ valid, invalid ].to_json

    post import_cards_path, params: { import: { raw_text: json, new_game_name: 'Import Test', new_game_edition: 'E' } }
    follow_redirect!

    # should have imported the good one
    expect(response.body).to include('Imported 1 cards')
    expect(Card.find_by(name: 'ImportGood')).not_to be_nil
    # bad one should not be present
    expect(Card.find_by(name: 'ImportBad')).to be_nil

    # There should be a report file in tmp with the expected counts
    reports = Dir.glob(Rails.root.join('tmp','cards_import_report_*.json')).sort
    expect(reports).not_to be_empty
    report = JSON.parse(File.read(reports.last))
    expect(report['created']).to eq(1)
    expect(report['failed']).to eq(1)
  end
end
