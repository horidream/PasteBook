
# platform :ios, '9.3'

target 'PasteBook' do
use_frameworks!
	pod 'EZSwiftExtensions'
    pod 'FMDB'
    pod 'Dropper'
	pod 'FoldingCell'
end



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
  end