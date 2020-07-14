#!/usr/bin/env ruby

require 'xcodeproj'

### This scripts fixes an Xcode project created using Swift Package Manager,
### by adding valid bundle identifier and build number.
### 
### This fix is required for Carthage binary distribution

# Usage: script path_to_xcodeproj
unless ARGV.length > 0
  puts "Usage: ruby #{__FILE__} path_to_xcodeproj"
  exit 1
end

project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)
target = project.targets.find do |target| 
    target.name == 'RxCombine'
end

config = target.build_configuration_list
config.set_setting('PRODUCT_BUNDLE_IDENTIFIER', 'com.CombineCommunity.RxCombine')
config.set_setting('CURRENT_PROJECT_VERSION', '1')

project::save()
