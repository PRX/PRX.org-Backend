# encoding: utf-8

class Api::ImageRepresenter < Api::BaseRepresenter
  include NestedImage

  def self_url(represented)
    nested_image_path(represented) || super
  end

  property :id, writeable: false
  property :filename, writeable: false
  property :size
  property :width
  property :height
  property :caption
  property :credit
  property :status, writeable: false
  property :purpose
  property :dimension_errors

  # provide an accessible url to the image media file for upload
  property :upload, readable: false

  link :enclosure do
    {
      href: represented.public_url(version: 'medium'),
      type: represented.content_type || 'image'
    } if represented.id
  end

  link :original do
    {
      href: represented.public_url(version: 'original'),
      type: represented.content_type || 'image'
    } if represented.id
  end
end
