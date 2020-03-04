require 'test_helper'

class TestImage < Image
  self.table_name = 'piece_images'
end

describe Image do
  let(:image) { TestImage.new }

  it 'is abstract and has no table' do
    Image.table_name.must_be_nil
  end

  it 'defines constants' do
    Image::COMPLETE.wont_be_nil
    Image::PURPOSES.wont_be :blank?
  end

  it 'knows if the state is final' do
    TestImage.new(status: Image::COMPLETE).must_be :fixerable_final?
    TestImage.new(status: Image::FAILED).wont_be :fixerable_final?
  end

  describe '#square?' do
    it 'is not square if dims are missing' do
      image.height.must_be_nil
      image.width.must_be_nil
      image.square?.must_equal false
    end

    it 'is not square if dims are unequal' do
      image.height = 1
      image.width = 2
      image.square?.must_equal false
    end

    it 'is square if dims equal' do
      image.height = 1
      image.width = 1
      image.square?.must_equal true
    end
  end

  describe '#bounded?' do
    it 'is not bounded if dims are missing' do
      image.height.must_be_nil
      image.width.must_be_nil
      image.bounded?(99, 100).must_equal false
    end

    it 'is bounded if the height and width are within pixel range' do
      image.height = 100
      image.width = 100
      image.bounded?(99, 100).must_equal true
    end

    it 'is not bounded if one an image dimension is outside the range' do
      image.height = 100
      image.width = 98
      image.bounded?(99, 100).must_equal false
    end
  end

  describe '#dimension_errors' do
    before do
      image.purpose = Image::THUMBNAIL
    end

    it 'has invalid dimensions if there are dimension errors' do
      image.square?.must_equal false
      image.dimension_errors.count.must_equal 2
      image.invalid_dimensions?.must_equal true
    end

    it 'creates a list of error messages if there are dimension errors' do
      # not square or bounded for thumbnail
      image.height = 1000
      image.width = 1500

      image.dimension_errors.count.must_equal 2
      image.dimension_errors.full_messages.first.must_equal 'Image must be square.'
      image.dimension_errors.full_messages.second.must_equal 'Image dimensions 1500x1000 must be less than 300 pixels.'
    end

    it 'sets an appropriate error message if there are no dimensions' do
      image.dimension_errors.count.must_equal 2
      image.dimension_errors.full_messages.must_include 'Image dimensions must be less than 300 pixels.'
    end
  end

end
