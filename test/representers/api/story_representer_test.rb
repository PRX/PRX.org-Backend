# encoding: utf-8

require 'test_helper'

describe Api::StoryRepresenter do

  let(:story)       { build_stubbed(:story_with_audio, audio_versions_count: 1, id: 212) }
  let(:representer) { Api::StoryRepresenter.new(story) }
  let(:json)        { JSON.parse(representer.to_json) }

  it 'create representer' do
    representer.wont_be_nil
  end

  it 'use representer to create json' do
    json['id'].must_equal story.id
  end

  it 'does not serialize a length property' do
    json.keys.wont_include('length')
  end

  it 'serializes the length of the story as duration' do
    story.stub(:duration, 212) do
      json['duration'].must_equal 212
    end
  end

  it 'serializes the default image' do
    image = create(:story_image)
    story.stub(:default_image, image) do
      json['_links']['prx:image']['href'].must_match /#{image.id}/
    end
  end

  it 'will not serialize default image when not available' do
    story.stub(:default_image, nil) do
      json['_links'].keys.wont_include 'prx:image'
    end
  end

  it 'has a profile for the default image' do
    image = create(:story_image)
    representer.stub(:prx_model_uri, 'string') do
      story.stub(:default_image, image) do
        json['_links']['prx:image']['profile'].must_equal 'string'
      end
    end
  end

  it 'includes a content advisory' do
    sigil = 'sigil'
    story.stub(:content_advisory, sigil) do
      json['contentAdvisory'].must_equal sigil
    end
  end

  it 'includes timing and cues' do
    sigil = 'sigil'
    story.stub(:timing_and_cues, sigil) do
      json['timingAndCues'].must_equal sigil
    end
  end

  it 'includes topics, tones and formats as tags' do
    tags = ['Art', 'Women', 'Fresh Air-ish']
    story.stub(:tags, tags) do
      json['tags'].must_equal tags
    end
  end

  describe 'series info' do
    let(:schedule) { create(:schedule) }
    let(:series) { schedule.series }
    let(:story) { build_stubbed(:story, series: series, episode_number: 2) }
    let(:representer) { Api::StoryRepresenter.new(story) }
    let(:json) { JSON.parse(representer.to_json) }

    it 'links to the series' do
      json['_links']['prx:series']['href'].must_match /#{series.id}/
    end

    it 'includes episode number' do
      json['episodeNumber'].must_equal 2
    end

    it 'includes episode date' do
      json['episodeDate'].must_equal story.episode_date
    end

    it 'has none of this when story is not in a series' do
      story2 = build_stubbed(:story)
      json = JSON.parse(Api::StoryRepresenter.new(story2).to_json)
      json['_links'].keys.wont_include('prx:series')
      json.keys.wont_include('episode_number')
      json.keys.wont_include('episode_date')
    end
  end

  describe Api::Min::StoryRepresenter do
    let(:representer) { Api::Min::StoryRepresenter.new(story) }

    it 'serializes the length of the story as duration' do
      story.stub(:duration, 212) do
        json['duration'].must_equal 212
      end
    end
  end
end
