require 'factory_bot'
require 'pry'

FactoryBot.define do
  factory :post, class: MyApp::Post do
    skip_create
    sequence(:id) {|n| n }
    sequence(:title) {|n| "Title for Post #{n}" }
    sequence(:body) {|n| "Body for Post #{n}" }

    trait :with_author do
      association :author, factory: :user
    end

    trait :with_long_comments do
      after(:create) do |object|
        long_comments = create_list(:long_comment, 2, post: object)
        object.long_comments = long_comments
      end
    end
  end

  # Post with some added property to test inheritance in serializer.
  factory :tagged_post, class: MyApp::TaggedPost do
    skip_create
    sequence(:id) {|n| n }
    sequence(:title) {|n| "Title for TaggedPost #{n}" }
    sequence(:body) {|n| "Body for TaggedPost #{n}" }
    sequence(:tag) {|n| "Tag for TaggedPost #{n}" }

    trait :with_author do
      association :author, factory: :user
    end
  end

  factory :long_comment, class: MyApp::LongComment do
    skip_create
    sequence(:id) {|n| n }
    sequence(:body) {|n| "Body for LongComment #{n}" }
  end

  factory :user, class: MyApp::User do
    skip_create
    sequence(:id) {|n| n }
    sequence(:name) {|n| "User ##{n}"}
  end

  factory :underscore_test, class: MyApp::UnderscoreTest do
    skip_create
    sequence(:id) {|n| n }
  end
end
