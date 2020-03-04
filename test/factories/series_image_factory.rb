FactoryGirl.define do
  factory :series_image do

    series
    purpose 'profile'
    height 1400
    width 1400

    after(:create) { |af| af.update_file!('test.png') }

  end
end
