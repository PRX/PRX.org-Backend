# encoding: utf-8

class Api::Auth::StoryMinRepresenter < Api::Min::StoryRepresenter
  # just make sure "self" stays under authorization, because unpublished
  # stories won't exist under the public stories path
  def self_url(r)
    api_authorization_story_path(r)
  end
end
