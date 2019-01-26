Pod::Spec.new do |spec|
  spec.name             = 'YXFDCategories'
  spec.version          = '0.0.9'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/enjoyor-runlu/YXFDCategories'
  spec.author           = { '' => '' }
  spec.summary          = 'YXFDCategories.'

  spec.source           = { :git => 'https://github.com/enjoyor-runlu/YXFDCategories.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '8.0'

  spec.source_files = 'YXFDCategories/Classes/*.{h,m}'

  spec.frameworks = 'UIKit', 'Foundation'

  spec.dependency 'SAMKeychain'
end

