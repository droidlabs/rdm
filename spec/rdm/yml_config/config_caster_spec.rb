require 'spec_helper'

describe Rdm::ConfigCaster do
  subject { described_class.new(env) }

  describe "#to_hcast_string" do
    context 'for string env' do
      let(:env) {
        Rdm::EnvConfig.new(
          name:        :string_env,
          type:        :string
        )
      }

      it 'generates proper string' do
        expect(
          subject.to_hcast_string(env)
        ).to eq("string :string_env, optional: false")
      end
    end

    context 'for array env' do
      let(:env) {
        Rdm::EnvConfig.new(
          name:        :array_env,
          type:        :array,
          each: [
            Rdm::EnvConfig.new(
              name:        :string_env,
              type:        :string
            )
          ]
        )
      }

      it 'generates proper string' do
        expect(
          subject.to_hcast_string(env)
        ).to eq("array :array_env, optional: false, each: :string")
      end
    end

    context 'for hash env' do
      let(:env) {
        Rdm::EnvConfig.new(
          name:        :hash_env,
          type:        :hash,
          each: [
            Rdm::EnvConfig.new(
              name:        :string_env,
              type:        :string
            )
          ]
        )
      }

      it 'generates proper string' do
        expect(
          subject.to_hcast_string(env)
        ).to eq("hash :hash_env, optional: false do \n  string :string_env, optional: false \nend")
      end
    end
  end
end