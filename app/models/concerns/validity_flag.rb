# encoding: utf-8

module ValidityFlag
  # cross purpose
  UPLOADED         = 'uploaded'.freeze
  NOTFOUND         = 'not found'.freeze
  VALID            = 'valid'.freeze
  INVALID          = 'invalid'.freeze
  INVALID_IMAGE_SIZE = 'invalid_image_size'.freeze
  FAILED           = 'failed'.freeze
  COMPLETE         = 'complete'.freeze
  VALIDATING       = 'validating'.freeze

  # audio files
  TRANSFORMING     = 'creating mp3s'.freeze
  TRANSFORM_FAILED = 'creating mp3s failed'.freeze
  TRANSFORMED      = 'mp3s created'.freeze
  SINGLE_CHANNEL   = 'Single Channel'.freeze
  DUAL_CHANNEL     = 'Dual Channel'.freeze
  STEREO           = 'Stereo'.freeze
  JOINT_STEREO     = 'JStereo'.freeze

  # images
  PROFILE          = 'profile'.freeze
  THUMBNAIL        = 'thumbnail'.freeze
  PURPOSES         = [PROFILE, THUMBNAIL].freeze
end
