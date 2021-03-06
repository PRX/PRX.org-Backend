# encoding: utf-8

require 'test_helper'

describe Api::PodcastImportRepresenter do
  let(:podcast_import) { FactoryGirl.create(:podcast_import) }
  let(:representer) { Api::PodcastImportRepresenter.new(podcast_import) }
  let(:json) { JSON.parse(representer.to_json) }

  def get_link_href(name)
    json['_links'][name] ? json['_links'][name]['href'] : nil
  end

  it 'handles a deleted series' do
    podcast_import.series.destroy
    podcast_import.reload
    get_link_href('prx:series').must_equal nil
  end

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal podcast_import.id
  end

  it 'keeps the self url in the authorization namespace' do
    get_link_href('self').must_match /authorization\/podcast_imports\/\d+/
  end

  it 'has basic attributes and links' do
    json['status'].must_equal 'created'
    json['url'].must_equal 'http://feeds.prx.org/transistor_stem'
    json['feedEpisodeCount'].must_equal 10
    get_link_href('prx:series').must_match /series/
  end

  it 'represents a podcast import that is not persisted' do
    representer = Api::PodcastImportRepresenter.new(PodcastImport.new(url: 'http://google.horse'))
    json = JSON.parse(representer.to_json)
    json['url'].must_equal 'http://google.horse'
    json['_links']['self']['href'].must_match /authorization\/podcast_imports$/
  end

  it 'renders a nil feed_episode_count' do
    podcast_import.feed_episode_count = nil
    json = JSON.parse(representer.to_json)
    json['feedEpisodeCount'].must_equal nil
  end

  it 'renders a numeric feed_episode_count' do
    podcast_import.feed_episode_count = 10
    json = JSON.parse(representer.to_json)
    json['feedEpisodeCount'].must_equal 10
  end
end
