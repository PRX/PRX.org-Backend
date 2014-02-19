# encoding: utf-8

class Api::StoryRepresenter < Roar::Decorator
  include Roar::Representer::JSON::HAL

  property :id

# * Title
  property :title

# * Length
  property :length

# * Short Description
  property :short_description

# * Full Description
  property :description

# * Date added to PRX
  property :published_at

# * Date produced
  property :produced_on

# * Points
  property :points

# * Related Websites
  property :related_website

# * Broadcast history
  property :broadcast_history

# * Timing & Cues
  property :timing_and_cues, decorator_scope: true

  def timing_and_cues
    represented.default_audio_version.try(:timing_and_cues)
  end

  link :self do 
    api_story_path(represented)
  end

# * Producer Name (producing account?)
# * Producing Account
#   * Name
#   * Username
#   * Location
#   * Photo
#   * Social Media Links
  link :account do
    { href: api_account_path(represented.account), name: represented.account.name }
  end
  property :account, embedded: true, class: Account, decorator: Api::AccountRepresenter

  link :image do
    api_story_story_image_path(represented, represented.default_image.id) if represented.default_image
  end
  property :default_image, as: :image, embedded: true, class: StoryImage, decorator: Api::ImageRepresenter

# * Audio Files
  links :audio do
    represented.default_audio.collect{ |a| { href: api_audio_file_path(a), name: a.label } }
  end
  collection :default_audio, as: :audio, embedded: true, class: AudioFile, decorator: Api::AudioFileRepresenter

  link :license do
    api_story_license_path(represented, represented.license.id)
  end

# * Musical Works
  link :musical_works do
    api_story_musical_works_path(represented)
  end

  links :audio_versions do
    represented.audio_versions.collect{ |a| { href: api_audio_version_path(a), name: a.label } }
  end

# * image(s)
  links :images do
    represented.images.collect{ |a| { href: api_story_story_image_path(represented, a) } } unless represented.images.empty?
  end

end

# TODO:
# * List of Producers
# * Licensing terms
# * tags

# WAIT:
# * Producing Account's other Pieces (Doesn't make sense for right now)

# requires castle integration
# * Purchase Count
# * Listen Count (don't know if this makes sense to have here)

# requires search/solr integration
# * Related Pieces (obviously low priority)

# requires fb integration
# * Like Count (don't think this exists)

# doesn't exist
# * Accomplishments (Don't think this exists)
