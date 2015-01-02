Target = Struct.new(:target, :platform, :platform_version)

targets = [ Target.new('TWTValidation', :osx, '10.8'), 
            Target.new('TWTValidation-iOS', :ios, '6.0'), 
            Target.new('libTWTValidation', :ios, '6.0') ]

targets.each do |t|
  target t.target.to_sym do
    platform t.platform, t.platform_version

    # Pods for the framework/library targets
    pod 'URLMock/SubclassResponsibility', '~> 1.2.3'
  end

  target "#{t.target}Tests".to_sym do
    platform t.platform, t.platform_version

    # Pods for the test targets
    #   Note that test targets inherit libraries from the main targets. Right now, 
    #   the project uses the main target’s xcconfig files for both the main and test
    #   targets. Also, the libTWTValidationTests target explicitly overrides the linking
    #   flags to not link anything from the pods. You’ll have to come up with a better
    #   solution to this problem should you add any pods here. 
  end
end
