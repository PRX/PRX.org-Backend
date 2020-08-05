# encoding: utf-8

class Authorization
  extend ActiveModel::Naming
  include HalApi::RepresentedModel

  attr_accessor :token

  delegate :resources, to: :token

  def initialize(token)
    @token = token
  end

  def id
    default_account.id
  end

  def default_account
    User.find(token.user_id).default_account
  end

  def account_ids(scope = nil)
    token.resources(scope).map(&:to_i)
  end

  def token_auth_accounts
    @token_auth_accounts ||= begin
      token_ids = account_ids(:read_private)
      Account.where(id: token_ids) unless token_ids.empty?
    end
  end

  def token_auth_stories
    @token_auth_stories ||= begin
      token_ids = account_ids(:read_private)
      Story.where(account_id: token_ids) unless token_ids.empty?
    end
  end

  def token_auth_series
    @token_auth_series ||= begin
      token_ids = account_ids(:read_private)
      Series.where(account_id: token_ids) unless token_ids.empty?
    end
  end

  def podcast_imports
    @podcast_imports ||= begin
      token_ids = account_ids(:read_private)
      PodcastImport.where(account_id: token_ids) unless token_ids.empty?
    end
  end

  def cache_key
    key_components = ['c', self.class.model_name.cache_key]
    key_components << OpenSSL::Digest::MD5.hexdigest(token.resources(:read_private).sort.join(' '))
    ActiveSupport::Cache.expand_cache_key(key_components)
  end

  def to_model
    self
  end

  def persisted?
    false
  end
end
