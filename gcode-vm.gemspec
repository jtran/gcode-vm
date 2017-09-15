# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcode_vm/version'

Gem::Specification.new do |spec|
  spec.name          = "gcode-vm"
  spec.version       = GcodeVm::VERSION
  spec.authors       = ["Jonathan Tran"]
  spec.email         = ["jon@voxel8.com"]

  spec.summary       = %q{G-code virtual machine and post-processing DSL}
  spec.homepage      = "https://github.com/Voxel8/gcode-vm"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 5.1", "< 6"
  spec.add_runtime_dependency "parslet", "~> 1.8"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.10"
end