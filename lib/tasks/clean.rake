require 'rake/clean'

CLEAN.include("**/*.gem", "**/*.rbx", "**/*.rbc", "ruby.core", "**/*.lock")
