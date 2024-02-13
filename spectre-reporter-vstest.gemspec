# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "spectre-reporter-vstest"
  spec.version       = "1.0.6"
  spec.authors       = ["Christian Neubauer"]
  spec.email         = ["christian.neubauer@ionos.com"]

  spec.summary       = "A VSTest reporter for spectre"
  spec.description   = "Writes a VSTest report for spectre test run, which can be used in Azure DevOps"
  spec.homepage      = "https://github.com/ionos-spectre/spectre-reporter-vstest"
  spec.license       = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ionos-spectre/spectre-reporter-vstest"
  spec.metadata["changelog_uri"]   = "https://github.com/ionos-spectre/spectre-reporter-vstest/blob/master/CHANGELOG.md"

  spec.files        += Dir.glob("lib/**/*")
  spec.files        += Dir.glob("resources/**/*")
  spec.require_paths = ["lib"]

  spec.add_dependency "spectre-core", ">= 1.14.3"
end
