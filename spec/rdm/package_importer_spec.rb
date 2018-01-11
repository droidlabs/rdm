require 'spec_helper'

describe Rdm::PackageImporter do
  def build_package(name, dependencies: [])
    package = Rdm::Package.new
    package.name(name)
    package.path = name
    dependencies.each do |dependency|
      package.import(dependency)
    end
    package.environment do
      array 'some_key', each: :string do
        length({ min: 3 })
      end
    end

    package
  end

  def build_source(packages:)
    source = Rdm::Source.new(root_path: nil)
    source.init_with(packages: packages)
    source
  end

  before(:each) do
    Rdm::PackageImporter.reset!
    Rdm::ConfigManager.reset!

    Rdm.setup do
      config_path File.expand_path(File.join(__dir__, '../fixtures/app.yml'))
    end
  end

  describe "#import_package" do
    subject { Rdm::PackageImporter }

    context "no group given" do
      it "imports all depended global packages" do
        web_pack = build_package("web", dependencies: ["core"])
        core_pack = build_package("core")
        source = build_source(packages: {"web" => web_pack, "core" => core_pack})

        imported = subject.import_package("web", source: source)
        expect(imported).to include("core")
      end
    end

    context "group given" do
      it "imports global and group dependencies" do
        web_pack = build_package("web", dependencies: ["core"])
        web_pack.dependency "test" do
          web_pack.import('factory')
        end
        core_pack = build_package("core")
        factory_pack = build_package("factory")

        source = build_source(packages: {"web" => web_pack, "core" => core_pack, "factory" => factory_pack})

        imported = subject.import_package("web", source: source, group: "test")
        expect(imported).to include("factory")
      end

      it "does not import not required group" do
        web_pack = build_package("web", dependencies: ["core"])
        web_pack.dependency "test" do
          web_pack.import('factory')
        end
        core_pack = build_package("core")
        factory_pack = build_package("factory")

        source = build_source(packages: {"web" => web_pack, "core" => core_pack, "factory" => factory_pack})

        imported = subject.import_package("web", source: source)
        expect(imported).to_not include("factory")
      end
    end

    context 'sets config variables' do
      it 'only for imported packages' do
        web_pack     = build_package("web", dependencies: ["core"])
        core_pack    = build_package("core")
        factory_pack = build_package("factory")
        
        source = build_source(packages: {"web" => web_pack, "core" => core_pack, "factory" => factory_pack})

        imported = subject.import_package("web", source: source)

        expect(Rdm::ConfigManager.web).to match({:some_key => ["value1", "value2", "value3"]})
        expect(Rdm::ConfigManager.core).to match({:some_key => ["value1", "value2", "value3"]})

        expect{
          Rdm::ConfigManager.factory
        }.to raise_error(
          ArgumentError, ":factory configuration was not defined for current package. Add `import 'factory'` to your Package.rb file"
        )
      end
    end
  end
end
