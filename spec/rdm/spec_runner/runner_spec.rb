require 'spec_helper'

describe Rdm::SpecRunner::Runner do
  include ExampleProjectHelper

  before { initialize_example_project }
  after  { reset_example_project }

  it 'run some test' do

  end
end