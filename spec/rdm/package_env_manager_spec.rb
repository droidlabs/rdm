require 'spec_helper'

describe Rdm::PackageEnvManager do
  let(:env_instance) { described_class.new }

  it do
    env_instance.load_hash({
      hello: 'world',
      foo: {
        baz: 'bar'
      }
    })

    env_instance.load_hash({
      logging: {
        app_name: 'nikita'
      }
    })

    expect(env_instance.hello).to eq('world')
    expect(env_instance.logging).to be_a(described_class)
    expect(env_instance.logging.app_name).to eq('nikita')
  end
end

