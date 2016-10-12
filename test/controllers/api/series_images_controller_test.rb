require 'test_helper'

describe Api::SeriesImagesController do
  let(:user) { create(:user) }
  let(:series) { create(:series, account: user.individual_account) }
  let(:series_image) { create(:series_image, series: series) }
  let(:token) { StubToken.new(series.account.id, ['member']) }

  before(:each) do
    class << @controller; attr_accessor :prx_auth_token; end
    @controller.prx_auth_token = token
    @request.env['CONTENT_TYPE'] = 'application/json'
    clear_messages
  end

  it 'should show' do
    series_image
    get(:show, api_request_opts(series_id: series_image.series_id))
    assert_response :success
  end

  it 'should update' do
    image_hash = { credit: 'blah credit' }
    put(:update, image_hash.to_json, api_request_opts(series_id: series.id, id: series_image.id))
    assert_response :success
    last_message['subject'].to_s.must_equal 'image'
    last_message['action'].to_s.must_equal 'update'
    SeriesImage.find(series_image.id).credit.must_equal('blah credit')
  end

  it 'should create' do
    original = series_image
    original.id.must_equal series.image.id

    image_hash = {
      upload: 'http://thisisatest.com/guid1/image.gif',
      set_series_uri: api_series_url(series)
    }

    post(:create, image_hash.to_json, api_request_opts(series_id: series.id))
    assert_response :success
    last_message['subject'].to_s.must_equal 'image'
    last_message['action'].to_s.must_equal 'create'
    new_image = JSON.parse @response.body

    original.id.wont_equal new_image['id']
    series.image(true).id.must_equal new_image['id']
  end
end
