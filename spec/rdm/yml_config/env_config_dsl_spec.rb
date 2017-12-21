require 'spec_helper'

describe Rdm::EnvConfigDSL do
  subject { described_class.new }
  let(:env_context) {
    Proc.new do
      string :url, optional: true do
        length({ min: 4, max: 7, equal_to: 2 })
      end

      array :connections, each: :string, default: [4] do
        size({ min: 0, max: 20})
      end

      hash :log_level do
        symbol :output do
          inclusion({ in: [:warn, :debug, :fatal, :error, :info] })
        end

        integer :level
      end

      array :some_array, each: :hash do
        string :key do
          length({ min: 4, max: 10 })
        end

        string :one_more_key, optional: true
      end
    end
  }

  it 'handle dsl' do
    subject.instance_exec(&env_context)
    
    expect(subject.data.map(&:to_hash)).to match(
      [
        {
          name:     :url,
          type:     :string,
          optional: true,
          validates: {
            length: {
              min:   4,
              max:   7,
              equal_to: 2
            }
          }
        },
        {
          name: :connections,
          type: :array,
          optional: false,
          default: [4],
          each: [
            {
              type: :string,
              optional: false,
              validates: {
                size: {
                  min: 0,
                  max: 20
                }
              }
            }
          ]
        },
        {
          name:     :log_level,
          type:     :hash,
          optional: false,
          each: [
            {
              name: :output,
              type: :symbol,
              optional: false,
              validates: {
                inclusion: {
                  in: [:warn, :debug, :fatal, :error, :info]
                }
              }
            },
            {
              name: :level,
              type: :integer,
              optional: false
            }
          ]
        },
        {
          name: :some_array,
          type: :array,
          optional: false,
          each: [
            {
              type: :hash,
              optional: false,
              each: [
                {
                  name: :key,
                  type: :string,
                  optional: false,
                  validates: {
                    length: {
                      min: 4,
                      max: 10
                    }
                  }
                },
                {
                  name: :one_more_key,
                  type: :string,
                  optional: true
                }
              ]
            }
          ]
        }
      ]
    )
  end
end