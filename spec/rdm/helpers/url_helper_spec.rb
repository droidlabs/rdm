require 'spec_helper'

describe Rdm::Helpers::PathHelper do
  include ExampleProjectHelper

  describe "::package_path" do
    subject { Class.new }

    before do
      subject.extend(described_class)

      @example_path    = initialize_example_project
    end

    after do
      reset_example_project(path: @example_path)
    end

    context "if rdm is not initialized" do
      before do
        @file_without_rdm = File.join(File.dirname(@example_path), 'path_helper_example.rb')
      end

      it "raises Rdm::Errors::SourceFileDoesNotExist error" do
        expect{
          Rdm.package_path(:core, current_file: @file_without_rdm)
        }.to raise_error(Rdm::Errors::SourceFileDoesNotExist)
      end
    end

    context "with invalid package name" do
      before do
        @file_with_invalid_package_name = File.join(@example_path, 'path_helper_example.rb')
      end

      it "raises Rdm::Errors::PackageDoesNotExist error" do
        expect{
          Rdm.package_path(:invalid_package_name, current_file: @file_with_invalid_package_name)
        }.to raise_error(Rdm::Errors::PackageDoesNotExist)
      end
    end

    context "with valid package name" do
      before do
        @example_file = File.join(@example_path, 'path_helper_example.rb')
      end

      it "returns path to file" do
        expect(
          subject.package_path(:core, current_file: @example_file)
        ).to eq(File.join(@example_path, "domain/core"))
      end
    end
  end
end