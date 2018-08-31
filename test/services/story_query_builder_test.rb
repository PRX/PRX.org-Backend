require 'test_helper'

describe StoryQueryBuilder do
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member'], 456) }
  let(:authorization) { Authorization.new(token) }
  let(:unauth_account) { create(:account) }

  it "#to_hash with authorization" do
    dsl = described_class.new(
      params: { from: 1, size: 5, },
      query: 'foo OR Bar',
      fielded_query: { something: '123', maybe: 'NULL', other: nil },
      authorization: authorization
    )
    dsl.to_hash.must_equal({
      _source: ["id"],
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: '(foo OR Bar) AND (something:(123))',
                default_operator: 'and',
                lenient: true,
                fields: %w( title short_description description ),
              },
            },
          ],
          filter: [
            { terms: { account_id: [account.id], _name: :authz } }
          ],
          must_not: [
            { exists: { field: :maybe } },
            { exists: { field: :other } },
          ],
        },
      },
      sort: [
        {
          published_at: {order: :desc, missing: '_last'},
          updated_at: {order: :desc, missing: '_last'}
        }
      ],
      size: 5,
      from: 1
    })
  end

  it "#to_hash without authorization" do
    dsl = described_class.new(
      params: { from: 1, size: 5, },
      query: 'foo OR Bar',
      fielded_query: { something: '123' },
    )
    dsl.to_hash.must_equal({
      _source: ["id"],
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: '(foo OR Bar) AND (something:(123))',
                default_operator: 'and',
                lenient: true,
                fields: %w( title short_description description ),
              },
            },
          ],
          filter: [
            {
              range: {
                published_at: {
                  lte: 'now',
                  _name: :published
                }
              }
            },
            {
              bool: {
                should: [
                  {
                    bool: {
                      must_not: [
                        {
                          exists: {
                            field: :deleted_at,
                            _name: :deleted_at_null
                          }
                        }
                      ]
                    }
                  },
                  {
                    term: {
                      app_version: {
                        value: 'v4',
                        _name: :app_version_v4
                      }
                    }
                  }
                ]
              }
            },
            {
              bool: {
                must_not: [
                  {
                    exists: {
                      field: :network_only_at,
                      _name: :network_visible
                    }
                  }
                ]
              }
            },
            {
              bool: {
                should: [
                  {
                    bool: {
                      must_not: [
                        {
                          term: {
                            'series.subscription_approval_status' => {
                              value: 'PRX Approved',
                              _name: :prx_series_approved
                            }
                          }
                        }
                      ]
                    }
                  },
                  {
                    bool: {
                      must_not: [
                        {
                          exists: {
                            field: 'series.subscriber_only_at',
                            _name: :series_subscriber_only_at
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ],
        },
      },
      sort: [
        {
          published_at: {order: :desc, missing: '_last'},
          updated_at: {order: :desc, missing: '_last'}
        }
      ],
      size: 5,
      from: 1
    })
  end

  it "defaults to sane pagination" do
    dsl_hash = described_class.new(
      query: "foo OR Bar",
    ).to_hash
    dsl_hash[:size].must_equal Story::MAX_SEARCH_RESULTS
    dsl_hash[:from].must_equal 0
  end

  it "determines from/size from page param" do
    dsl_hash = described_class.new(
      params: { page: 3 },
      query: "foo OR Bar",
    ).to_hash
    dsl_hash[:size].must_equal Story::MAX_SEARCH_RESULTS
    dsl_hash[:from].must_equal( 2 * Story::MAX_SEARCH_RESULTS )
  end

  describe "parses date ranges" do
    it "when created_at is present" do
      some_time = Time.zone.parse("2016-03-25T02:55:57Z")
      dsl = described_class.new(
        fielded_query: {
          created_at: some_time.to_s,
          created_within: "6 months",
        },
        query: "foo OR Bar",
      )
      dsl.composite_query_string.must_equal(
        "(foo OR Bar) AND (created_at:[#{(some_time.utc - 6.months).iso8601} TO #{some_time.utc.iso8601}])"
      )
    end

    it "when created_at is not present defaults to relative-to-now" do
      Timecop.freeze do
        six_months_ago = (Time.current.utc - 6.months).iso8601
        dsl = described_class.new(
          fielded_query: {
            created_within: "6 months",
          },
          query: "foo OR Bar",
        )
        dsl.composite_query_string.must_equal(
          "(foo OR Bar) AND (created_at:[#{six_months_ago} TO now])"
        )
      end
    end
  end

  it "#structured_query" do
    dsl = described_class.new(
      fielded_query: { something: "123", maybe: 'NULL' },
      query: "foo OR Bar",
    )
    dsl.structured_query.must_be_instance_of FieldedSearchQuery
    dsl.structured_query.to_s.must_equal "something:(123)"
  end

  it "#composite_query_string" do
    dsl = described_class.new(
      fielded_query: { something: "123", maybe: 'NULL' },
      query: "foo OR Bar",
    )
    dsl.composite_query_string.must_equal "(foo OR Bar) AND (something:(123))"
  end

  it "#humanized_query_string" do
    dsl = described_class.new(
      fielded_query: { something: "123", maybe: 'NULL' },
      query: "foo OR Bar",
    )
    dsl.humanized_query_string.must_equal "(foo OR Bar) AND (Something:(123))"
  end
end
