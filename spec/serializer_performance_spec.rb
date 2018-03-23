require 'active_model/errors'
require 'active_model/naming'
require 'active_model/translation'

perf_expectations = [
  { c: 1, s: 0.002 },
  { c: 10, s: 0.004 },
  { c: 100, s: 0.01 },
  { c: 1000, s: 0.05 }
]

describe JSONAPI::Serializer do
  describe 'serializer is performant' do
    perf_expectations.each do |pe|
      it "serializes a #{pe[:c]} entities in under #{pe[:s]} seconds" do
        result = create_list(:post, pe[:c], :with_author, :with_long_comments)

        expect {
          JSONAPI::Serializer.serialize(result, include: [], namespace: Api::V1, is_collection: true)
        }.to perform_under(pe[:s]).sec
      end
    end
  end
end
