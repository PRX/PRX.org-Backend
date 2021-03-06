# encoding: utf-8

class Api::Min::UserRepresenter < Api::BaseRepresenter
  property :id, writeable: false
  property :first_name
  property :last_name
  property :login

  link :accounts do
    {
      href: api_user_accounts_path(represented),
      count: represented.accounts.count
    } if represented.id
  end
  embed :accounts, paged: true, item_class: Account, item_decorator: Api::Min::AccountRepresenter, zoom: false

  link :image do
    {
      href:  api_user_user_image_path(represented),
      title: represented.image.try(:filename)
    } if represented.id
  end
  embed :image, class: Image, decorator: Api::ImageRepresenter
end
