# encoding: utf-8

class User < BaseModel
  acts_as_paranoid

  # DON'T touch the account, as you'll create an infinite loop
  belongs_to :default_account, -> { with_deleted }, class_name: 'Account', foreign_key: 'account_id'

  has_one :address, as: :addressable
  has_one :image, -> { where(parent_id: nil) }, class_name: 'UserImage', dependent: :destroy

  has_many :memberships
  has_many :accounts, through: :memberships, source: :account
  has_many :producers

  after_commit :create_individual_account, on: [:create]

  validates_uniqueness_of :login

  def individual_account
    accounts.where('type = \'IndividualAccount\'').first
  end

  def individual_account=(account)
    update_attributes!(account_id: account.id)
    accounts.where(type: 'IndividualAccount').where.not(id: account.id).pluck(:id).each do |old_id|
      memberships.where(account_id: old_id).each { |m| memberships.destroy(m) }
    end
  end

  def create_individual_account
    return if individual_account
    User.transaction do
      ia = IndividualAccount.create!(opener_id: id, path: login, status: 'open')
      self.individual_account = ia
    end
  end

  def networks
    Network.joins('LEFT OUTER JOIN `network_memberships` on `network_memberships`.`network_id` = `networks`.`id`').
    where(['`networks`.`account_id` in (?) OR `network_memberships`.`account_id` in (?)', accounts.ids, accounts.ids])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def account_ids
    accounts.pluck(:id)
  end
end
