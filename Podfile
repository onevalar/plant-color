
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'

inhibit_all_warnings!
#use_modular_headers!
use_frameworks!

target 'PlantWidgetExtension' do

  # Codable
  pod 'CleanJSON' # https://github.com/Pircate/CleanJSON

  #https://github.com/realm/realm-cocoa
  # 数据库
  pod 'RealmSwift'

end

target 'PlantColor' do

  # OC

  # https://github.com/CoderMJLee/MJRefresh
  pod 'MJRefresh'

  # NavigationController
  # https://github.com/rickytan/RTRootNavigationController
  pod "RTRootNavigationController"

  # 全屏滑动返回手势
  # https://github.com/forkingdog/FDFullscreenPopGesture
  pod 'FDFullscreenPopGesture'

  # HUD
  # https://github.com/jdg/MBProgressHUD/
  pod 'MBProgressHUD'

  # http://www.woodpeck.cn/cnusage.html
  pod 'WoodPeckeriOS', :configurations => ['Debug']

  # 友盟
  pod 'UMCommon'
  pod 'UMDevice'
  # 可选集成，对应产品中稳定性模块（错误捕获），该功能已经独立成为新的应用性能监控产品U-APM
  pod 'UMAPM'

  # https://github.com/pujiaxin33/JXCategoryView
  pod 'JXCategoryView'

  # Swift

  # 富文本
  # https://github.com/Rightpoint/BonMot
  pod 'BonMot'

  # Codable
  pod 'CleanJSON' # https://github.com/Pircate/CleanJSON

  # 图片加载
  # https://github.com/onevcat/Kingfisher
  pod 'Kingfisher'

  #https://github.com/realm/realm-cocoa
  # 数据库
  pod 'RealmSwift'

  # Resources 管理
  # https://github.com/mac-cain13/R.swift
  pod 'R.swift'

  # 布局
  # https://github.com/SnapKit/SnapKit
  pod 'SnapKit'

  # Placeholder
  # https://github.com/Xiaoye220/EmptyDataSet-Swift
  pod 'EmptyDataSet-Swift'

  pod 'EmptyDataSetExtension'

  # https://github.com/InsectQY/QYUINavigationBarExtension
  pod 'QYUINavigationBarExtension'

  # https://github.com/nmdias/DefaultsKit
  pod 'DefaultsKit'

  # https://github.com/yeahdongcn/UIColor-Hex-Swift
  pod 'UIColor_Hex_Swift'

  # https://github.com/Pircate/EachNavigationBar
  pod 'EachNavigationBar'

  # https://github.com/SFSafeSymbols/SFSafeSymbols
  pod 'SFSafeSymbols'

  # https://github.com/Nirma/UIFontComplete
  pod 'UIFontComplete'

  # https://github.com/HeroTransitions/Hero
  pod 'Hero'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      # 注意：不强制设置 ARCHS，让 Xcode 自动处理，避免与 Realm xcframework 冲突

      # 解决重复库警告
      config.build_settings['OTHER_LDFLAGS'] ||= '$(inherited)'
      if config.build_settings['OTHER_LDFLAGS'].include?('-lc++')
        config.build_settings['OTHER_LDFLAGS'] = config.build_settings['OTHER_LDFLAGS'].gsub(/-lc\+\+/, '')
      end

      # 优化编译设置
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone' if config.name == 'Debug'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O' if config.name == 'Release'

      # 设置模块化头文件
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'

      # 解决符号链接警告
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'

      # 修复 Realm privacy bundle 与 Xcode 16+ 的兼容性问题（针对所有 target）
      # Xcode 16+ 的递归脚本输入检查会在 realm_objc_privacy.bundle 内查找二进制文件
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'

      # 关键修复：禁止 Pod target 的脚本沙箱
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'

      # Xcode 26 兼容性修复：禁用"显式模块构建"
      config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'

      # Xcode 26 兼容性修复：禁用递归脚本输入扫描（Pods project 全局）
      config.build_settings['USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES'] = 'NO'

      # Realm xcframework 不含 x86_64 模拟器切片，排除 Intel 架构避免架构不匹配错误
      # Apple Silicon Mac 上的模拟器本身就是 arm64，无需 x86_64
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386 x86_64'
    end
  end

  # ===== 关键修复 =====
  # CocoaPods 生成的 xcconfig 文件里硬写了 USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = YES
  # 必须从源头修改 xcconfig，同时删除主项目 targets 里的直接覆盖设置
  Dir.glob(File.join(installer.sandbox.root, 'Target Support Files', '**', '*.xcconfig')).each do |xcconfig_path|
    content = File.read(xcconfig_path)
    if content.include?('USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = YES')
      File.write(xcconfig_path, content.gsub('USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = YES',
                                              'USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = NO'))
    end
  end

  # 主项目（PlantColor.xcodeproj）targets 直接 build settings 里硬写了 YES，会覆盖 xcconfig
  # 删除这个直接覆盖，让 target 从上面已修改的 xcconfig 继承 NO
  # 同时排除 x86_64 架构，确保模拟器只用 arm64
  installer.aggregate_targets.each do |aggregate_target|
    user_project = aggregate_target.user_project
    user_project.targets.each do |user_target|
      user_target.build_configurations.each do |config|
        config.build_settings.delete('USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES')
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386 x86_64'
      end
    end
    user_project.save
  end

  # 通过 product_type 精确检测所有资源 bundle targets
  # 覆盖 Kingfisher-Kingfisher、MJRefresh-MJRefresh、SnapKit-SnapKit_Privacy 等
  # Xcode 26 对这些无可执行文件的 bundle 会尝试查找同名二进制，导致构建失败
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) && target.product_type == 'com.apple.product-type.bundle'
      target.build_configurations.each do |config|
        config.build_settings['SKIP_INSTALL'] = 'YES'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        config.build_settings['COPY_PHASE_STRIP'] = 'NO'
        config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
        config.build_settings['USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES'] = 'NO'
      end
    end
  end

  # 修复R.swift脚本
  installer.pods_project.targets.each do |target|
    if target.name == 'PlantColor'
      target.build_phases.each do |build_phase|
        if build_phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
           build_phase.name == 'R.Swift'
          build_phase.always_out_of_date = '0'
          build_phase.output_paths = ['$SRCROOT/PlantColor/Resources/Generated/R.generated.swift']
        end
      end
    end
  end
end
