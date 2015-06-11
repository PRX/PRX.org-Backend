# encoding: utf-8

class Api::Min::StoryRepresenter < Api::BaseRepresenter

  property :id
  property :title
  property :short_description
  property :episode_number
  property :episode_identifier
  property :published_at
  property :produced_on

  property :duration, writeable: false
  property :points, writeable: false
  property :app_version, writeable: false

  alternate_link

  link :account do
    {
      href: api_account_path(represented.account),
      title: represented.account.name,
      profile: prx_model_uri(represented.account)
    } if represented.account
  end
  embed :account, class: Account, decorator: Api::Min::AccountRepresenter, zoom: false

  link :series do
    {
      href: api_series_path(represented.series),
      title: represented.series.title
    } if represented.series_id
  end
  embed :series, class: Series, decorator: Api::Min::SeriesRepresenter, zoom: false

  link :image do
    {
      href: polymorphic_path([:api, represented.default_image]),
      profile: prx_model_uri(represented.default_image)
    } if represented.default_image
  end
  embed :default_image, as: :image, decorator: Api::ImageRepresenter

  link :audio do
    {
      href: api_story_audio_files_path(represented.id),
      count: represented.default_audio.count
    } if represented.id
  end
  embed :default_audio, as: :audio, paged: true, item_class: AudioFile, per: :all

  link :promos do
    {
      href: api_story_promos_path(represented.id),
      count: represented.promos_audio.count
    } if represented.id
  end
  embed :promos_audio, as: :promos, paged: true, item_class: AudioFile
end
