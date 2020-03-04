# encoding: utf-8

class Image < BaseModel
  self.abstract_class = true

  include PublicAsset
  include Fixerable
  include ValidityFlag

  def self.profile
    order("field(purpose, '#{Image::PROFILE}') desc, created_at desc").first
  end

  def self.thumbnail
    order("field(purpose, '#{Image::THUMBNAIL}') desc, created_at desc").first
  end

  alias_attribute :upload, :upload_path

  mount_uploader :file, ImageUploader, mount_on: :filename
  skip_callback :commit, :after, :remove_file! # don't remove s3 file
  fixerable_upload :upload, :file

  before_validation do
    if upload
      self.status ||= UPLOADED
    end
  end

  # for backwards compatibility, null statuses are considered final
  def fixerable_final?
    status.nil? || status == COMPLETE
  end

  def self.policy_class
    ImagePolicy
  end

  def valid_dimensions?
    dimension_errors.empty?
  end

  def invalid_dimensions?
    !valid_dimensions?
  end

  def dimension_errors
    errs = ActiveModel::Errors.new(self)

    # percolate up useful info if possible
    dim_label = dims.all?(&:present?) ? "#{width}x#{height} " : ''

    case purpose
    when Image::PROFILE
      errs.add(:base, 'Image must be square.') if !square?

      errs.add(:base, "Image dimensions #{dim_label}must be greater than 1400 pixels and" \
        ' less than 3000 pixels.') if !bounded?(1400, 3000)
    when Image::THUMBNAIL
      errs.add(:base, 'Image must be square.') if !square?
      errs.add(:base, "Image dimensions #{dim_label}must be less than 300 pixels.") if !bounded?(0, 300)
    end

    errs
  end

  def dims
    [width, height]
  end

  def bounded?(min_range, max_range)
    dims.all?(&:present?) &&
    dims.max.between?(min_range, max_range) &&
      dims.min.between?(min_range, max_range)
  end

  def square?
    dims.all?(&:present?) &&
      height == width
  end

end
