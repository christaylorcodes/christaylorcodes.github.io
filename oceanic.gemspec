# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "oceanic"
  spec.version       = "0.1.0"
  spec.authors       = ["Chris Taylor"]
  spec.email         = ["ctaylor@christaylor.codes"]

  spec.summary       = "A modern dark Jekyll theme with Electric Blue accents"
  spec.description   = "Oceanic is a professional, modern dark theme for Jekyll featuring an Electric Blue and warm amber color palette. Perfect for tech portfolios, blogs, and project showcases. Includes responsive design, blog post layouts, project cards, and smooth animations."
  spec.homepage      = "https://github.com/christaylorcodes/oceanic-theme"
  spec.license       = "MIT"

  spec.metadata["plugin_type"] = "theme"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/christaylorcodes/oceanic-theme"
  spec.metadata["changelog_uri"] = "https://github.com/christaylorcodes/oceanic-theme/blob/main/CHANGELOG.md"

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(_(includes|layouts|sass)/|assets/|(LICENSE|README)((\.(txt|md|markdown)|$)))}i)
  end

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_runtime_dependency "jekyll", "~> 4.0"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.15"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.8"

  spec.add_development_dependency "bundler", "~> 2.0"
end
