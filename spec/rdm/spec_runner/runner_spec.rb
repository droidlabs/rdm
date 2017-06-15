require 'spec_helper'

describe Rdm::SpecRunner::Runner do
  include ExampleProjectHelper

  let(:input_params) { Rdm::SpecRunner::InputParams.new('') }

  before do
    @project_path = initialize_example_project
  end

  after do
    reset_example_project(path: @project_path)
  end

  it 'run some test' do
    expect(
      described_class.new(input_params, path: @project_path).run
    ).to eq(1)
  end
end