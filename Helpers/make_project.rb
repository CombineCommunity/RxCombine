#!/usr/bin/env ruby

require 'xcodeproj'

### This script creates an Xcode project using Swift Package Manager
### and then applies every needed configurations and other changes.
###
### Written by Shai Mishali, June 1st 2019.

# Make sure SPM is Installed
system("swift package > /dev/null 2>&1")
unless $?.exitstatus == 0
    puts "SPM is not installed"
    exit 1
end

# Make sure we have a Package.swift file
abort("Can't locate Package.swift") unless File.exist?("Package.swift")

# Attempt generating Xcode Project
system("swift package generate-xcodeproj --enable-code-coverage")

project = Xcodeproj::Project.open('RxCombine.xcodeproj')
targets = ['RxCombine', 'RxCombinePackageDescription', 'RxCombineTests', 'RxCombinePackageTests']
project.targets.each do |target|
    if targets.include?(target.name)
#         swiftlint = target.new_shell_script_build_phase('SwiftLint')
#         swiftlint.shell_script = <<-SwiftLint
# if which swiftlint >/dev/null; then
#     swiftlint
# else
#     echo "warning: SwiftLint not installed"
# fi       
#         SwiftLint

        # index = target.build_phases.index { |phase| (defined? phase.name) && phase.name == 'SwiftLint' }
        # target.build_phases.move_from(index, 0)
    else
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
            config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -suppress-warnings'
        end
    end
end

project::save()