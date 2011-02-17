Gem::Specification.new do |s|
  s.name     = "robworley-schema-validations"
  s.version  = "1.0.1"
  s.date     = "2011-02-15"
  s.summary  = "DRY up your ActiveRecord validations based on schema information."
  s.email    = "robert.worley@gmail.com"
  s.homepage = "http://github.com/robworley/schema-validations"
  s.description = "Validate ActiveRecord models based your database schema."
  s.has_rdoc = true
  s.authors  = ["Rob Worley"]
  s.files    = ["MIT-LICENSE",
                "README.rdoc",
                "schema_validations.gemspec",
                "lib/schema_validations.rb"
                ]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end
