### possible CLI interface for RDM

rdm init --test=minitest
rdm init --test=rspec

rdm init --console=irb
rdm init --console=pry

rdm gen.package some_package --path subsystems/some_package

rdm --version
rdm -v

rdm --help
rdm -h



### RDM public API:


Rdm.init("some/Package.rb")
Rdm.init("some/Package.rb", :test)



# Rdm::SourceParser.read_and_init_source(rdm_packages_path).packages

Rdm.source
# instance of Rdm::Source
Rdm.packages
