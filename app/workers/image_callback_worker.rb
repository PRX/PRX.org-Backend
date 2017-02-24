class ImageCallbackWorker
  include Shoryuken::Worker
  include ValidityFlag
  include Announce::Publisher

  class UnknownImageTypeError < StandardError; end

  shoryuken_options queue: "#{ENV['RAILS_ENV']}_cms_image_callback"

  def perform(_sqs_msg, job)
    image = find_image(job['type'], job['id'])
    image.filename = job['name']
    image.size = job['size']
    image.width = job['width']
    image.height = job['height']
    image.aspect_ratio = image.width / image.height.to_f if image.width && image.height

    mime_type = MIME::Types.type_for(job['format'] || '').first.try(:content_type)
    image.content_type = mime_type || job['format']

    if !job['downloaded']
      image.status = NOTFOUND
    elsif !job['valid']
      image.status = INVALID
    elsif !job['resized']
      image.status = FAILED
    else
      image.upload_path = nil
      image.status = COMPLETE
    end

    Shoryuken.logger.info("Updating #{job['type']}[#{image.id}]: status => #{image.status}")
    image.save!
    # announce the audio changes using the story as resource -- or do we want series?
    announce(:image, :update, id: image.story.id, resource: image.story)

  rescue ActiveRecord::RecordNotFound
    Shoryuken.logger.error("Record #{job['type']}[#{job['id']}] not found")
  rescue UnknownImageTypeError
    Shoryuken.logger.error("Unknown image type for message: #{job}")
  end

  def find_image(type, id)
    type = 'story_images' if type == 'piece_images'
    type_class = nil
    begin
      type_class = type.camelize.singularize.constantize
    rescue NameError
      raise UnknownImageTypeError.new
    end
    type_class.find(id)
  end
end
