require 'spec_helper'

describe Rdm::PackageImporter do
  def build_package(name, dependencies: [])
    package = Rdm::Package.new
    package.name(name)
    dependencies.each do |dependency|
      package.import(dependency)
    end
    package
  end

  describe "#import_package" do
    subject { Rdm::PackageImporter }

    context "no group given" do
      it "imports all depended global packages" do
        web_pack = build_package("web", dependencies: ["core"])
        core_pack = build_package("core")
        packages = {"web" => web_pack, "core" => core_pack}

        imported = subject.import_package("web", packages: packages)
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

        packages = {"web" => web_pack, "core" => core_pack, "factory" => factory_pack}

        imported = subject.import_package("web", packages: packages, group: "test")
        expect(imported).to include("factory")
      end

      it "does not import not required group" do
        web_pack = build_package("web", dependencies: ["core"])
        web_pack.dependency "test" do
          web_pack.import('factory')
        end
        core_pack = build_package("core")
        factory_pack = build_package("factory")

        packages = {"web" => web_pack, "core" => core_pack, "factory" => factory_pack}

        imported = subject.import_package("web", packages: packages)
        expect(imported).to_not include("factory")
      end
    end
  end
end