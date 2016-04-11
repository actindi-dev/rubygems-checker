gem_version = GemVersion.new("./Gemfile.lock")
validator = DangerousGemValidator.new
puts validator.invalid_gems(gem_version.gems).map {|x| x.join(', ')}
