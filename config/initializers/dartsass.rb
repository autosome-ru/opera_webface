Rails.application.config.dartsass.build_options << "--load-path=#{Rails.root.join("node_modules")}"
Rails.application.config.dartsass.build_options << "--no-charset"
Rails.application.config.dartsass.build_options << "--quiet-deps"
