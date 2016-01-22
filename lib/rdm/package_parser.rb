class Rdm::PackageParser
  def self.parse(package_content)
    spec = Rdm::Package.new
    spec.instance_eval(package_content)
    spec
  end
end