# encoding: utf-8

class Api::Auth::StoriesController < Api::StoriesController
  include ApiAuthenticated

  api_versions :v1

  filter_resources_by :account_id, :series_id, :network_id

  filter_params :highlighted, :purchased, :v4, :text, :noseries

  sort_params default: { updated_at: :desc },
              allowed: [:id, :created_at, :updated_at, :published_at, :title,
                        :episode_number, :position]

  announce_actions :create, :update, :delete, :publish, :unpublish

  represent_with Api::Auth::StoryRepresenter

  before_filter :check_user_network, only: [:index], if: -> { params[:network_id] }

  def check_user_network
    user_not_authorized unless current_user.networks.exists?(params[:network_id])
  end

  # ALL stories - not just published and visible
  def scoped(relation)
    relation
  end

  def filtered(resources)
    resources = resources.unseries if filters.noseries?
    super(resources)
  end

  def resources_base
    # If there is a network_id specified, use that network
    @stories ||= if params[:network_id]
      super.published
    else
      Authorization.new(prx_auth_token).token_auth_stories
    end
  end

  def create_resource
    super.tap do |story|
      story.creator_id = current_user.id
      story.account_id ||= story.series.try(:account_id)
      story.account_id ||= current_user.account_id
      story.account_id ||= current_user.approved_accounts.first.try(:id) # not sure if I should change this to look at token
    end
  end
end
