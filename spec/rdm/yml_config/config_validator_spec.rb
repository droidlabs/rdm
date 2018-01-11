require 'spec_helper'

describe Rdm::ConfigValidator do

  let(:hash_config) {
    {
      example_config: {
        example_array_config:   ['hello', 'world'],
        example_symbol_config:  :values,
        example_integer_config: 25,
        example_email_config:   'info@rdm.com'
      }
    }
  }

  let(:array_config) {
    Rdm::EnvConfig.new(
      name:      'example_array_config',
      type:      :array,
      validates: nil,
      children: [
        Rdm::EnvConfig.new(
          name: nil,
          type: :string,
          validates: {
            length: {
              equal_to: 5
            }
          }
        )
      ]
    )
  }
  let(:symbol_config) {
    Rdm::EnvConfig.new(
      name: 'example_symbol_config',
      type: :symbol,
      validates: {
        inclusion: {
          in: [:example, :symbol, :config, :values]
        }
      }
    )
  }
  let(:integer_config) {
    Rdm::EnvConfig.new(
      name: 'example_integer_config',
      type: :integer,
      validates: {
        numericality: {
          greater_than_or_equal_to: 5,
          less_than: 50
        }
      }
    )
  }
  let(:email_config) {
    Rdm::EnvConfig.new(
      name:     'example_email_config',
      type:     :string,
      optional: true,
      validates: {
        email: true,
        presence: true
      }
    )
  }

  let(:env_config) {
    Rdm::EnvConfig.new(
      name:      'example_config',
      type:      :hash,
      optional:  true,
      default:   nil,
      validates: nil,
      children: [
        array_config,
        symbol_config,
        integer_config,
        email_config
      ]
    )
  }

  describe '#validate' do
    context 'for symbol config' do
      it 'not raises error for valid params' do
        expect {
          described_class.new(symbol_config).validate!({example_symbol_config: :example})
        }.not_to raise_error
      end

      it 'raises ArgumentError if invalid params' do
        expect {
          described_class.new(symbol_config).validate!({example_symbol_config: :unpermitted_parameter})
        }.to raise_error ArgumentError
      end

      it 'returns OpenStruct' do
        expect(
          described_class.new(symbol_config).validate!({example_symbol_config: :example})
        ).to eq(OpenStruct.new({example_symbol_config: :example}))
      end
    end

    context 'for email config' do
      it 'not raises error for valid params' do
        expect {
          described_class.new(email_config).validate!({example_email_config: 'hello@world.ru'})
        }.not_to raise_error
      end

      it 'raises ArgumentError if invalid params' do
        expect {
          described_class.new(email_config).validate!({example_email_config: 'helloworld'})
        }.to raise_error ArgumentError
      end

      it 'returns OpenStruct' do
        expect(
          described_class.new(email_config).validate!({example_email_config: 'hello@world.ru'})
        ).to eq(OpenStruct.new({example_email_config: 'hello@world.ru'}))
      end
    end

    context 'for integer config' do
      it 'not raises error for valid params' do
        expect {
          described_class.new(integer_config).validate!({example_integer_config: 5})
        }.not_to raise_error
      end

      it 'not raises error for valid params' do
        expect {
          described_class.new(integer_config).validate!({example_integer_config: 4})
        }.to raise_error ArgumentError
      end

      it 'returns OpenStruct' do
        expect(
          described_class.new(integer_config).validate!({example_integer_config: 5})
        ).to eq(OpenStruct.new({example_integer_config: 5}))
      end
    end

    context 'for array config' do
      it 'not raises error for valid params' do
        expect {
          described_class.new(symbol_config).validate!({example_array_config: ['hello', 'world']})
        }.not_to raise_error
      end

      it 'returns OpenStruct' do
        expect(
          described_class.new(integer_config).validate!({example_array_config: ['hello', 'world']})
        ).to eq(OpenStruct.new({example_array_config: ['hello', 'world']}))
      end
    end

    context 'for hash config' do
      it 'not raises error for valid params' do
        expect {
          described_class.new(symbol_config).validate!({example_array_config: ['hello', 'world']})
        }.not_to raise_error
      end

      it 'returns OpenStruct' do
        expect(
          described_class.new(integer_config).validate!(
            {
              example_array_config: ['hello', 'world'],
              example_integer_config: 5,
              example_email_config: 'hello@world.pro',
              example_symbol_config: :example
            }
          )
        ).to match(
          OpenStruct.new(
            {
              example_array_config:   ['hello', 'world'],
              example_integer_config: 5,
              example_email_config:   'hello@world.pro',
              example_symbol_config:  :example
            }
          )
        )
      end
    end
  end
end