Gem::Specification.new do |s|
	s.name         = "dcaba_drone_brain"
	s.version      = "0.1"
	s.author       = "Daniel Caballero"
	s.email        = "dcaba@github.com"
	s.homepage     = "https://github.com/dcaba"
	s.summary      = "Ruby exercise pretending to resolve Google Hascode exercise"
	s.description  = File.read(File.join(File.dirname(__FILE__), 'README'))
	s.licenses     = ['MIT']

	s.files         = Dir["{bin,lib,spec}/**/*"] + %w(LICENSE README)
	s.test_files    = Dir["spec/**/*"]
	s.executables   = Dir["bin/*"]

	s.required_ruby_version = '>=1.9'
	s.add_development_dependency 'rspec'
end
