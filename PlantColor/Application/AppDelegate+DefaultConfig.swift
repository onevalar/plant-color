//
//  AppDelegate+DefaultConfig.swift
//  PlantColor
//
//  Created by QY on 2022/5/4.
//

import DefaultsKit

// MARK: - 用于设置 App 的默认配置

extension AppDelegate {

    func setAllDefaultConfig() {
        setColorDetailDefaultConfig()
        setTraditionalColorDetailDefaultConfig()
        setSettingDefaultConfig()
    }

    func setColorDetailDefaultConfig() {

        if Defaults().get(for: AppKey.isConfigDefaultColorDetail) ?? false {
            return
        }

        let config = ColorDetailConfig()
        config.id = .userId
        config.defaultNow.append(objectsIn: [.intro,
                                             .derivation,
                                             .food,
                                             .custom,
                                             .cultivation,
                                             .application,
                                             .medicinalEffect])

        config.defaultOther.append(objectsIn: [.literature,
                                               .story,
                                               .meanings])
        config.re.add()
        Defaults().set(true, for: AppKey.isConfigDefaultColorDetail)
    }

    func setSettingDefaultConfig() {

        if Defaults().get(for: AppKey.isConfigDefaultSetting) ?? false {
            return
        }
        
        let config = SettingConfig()
        config.id = .userId
        config.automaticSwitching = false
        config.randomSwitching = false
        config.switchingRate = "10s"
        config.showFigure = false
        config.showTone = true
        config.customContent = ""
        config.refreshRate = "1hour"
        config.re.add()
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(false, forKey: WidgetKitHelper.showFigure)
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(true, forKey: WidgetKitHelper.showTone)
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(config.refreshRate, forKey: WidgetKitHelper.refreshRate)
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(config.customContent, forKey: WidgetKitHelper.customContent)
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(0, forKey: WidgetKitHelper.currentIndex)
        WidgetKitHelper.reloadAllWidgets()

        /// 默认配置
        Defaults().set(true, for: AppKey.isConfigDefaultSetting)
    }

    /// 传统色详情页的默认版块。
    /// 版块内容补全后，默认全部显示；旧版本的设置当时并不影响页面，所以升级时直接重置一次。
    func setTraditionalColorDetailDefaultConfig() {

        let revision = 2
        if (Defaults().get(for: AppKey.traditionalDetailConfigRevision) ?? 0) >= revision {
            return
        }

        TraditionalColorDetailConfig.re.transaction { realm in
            realm.delete(realm.objects(TraditionalColorDetailConfig.self))
        }

        let config = TraditionalColorDetailConfig()
        config.id = .userId
        config.defaultNow.append(objectsIn: [.intro,
                                              .colorOrigin,
                                              .colorStory,
                                              .culturalCustoms,
                                              .artApplication,
                                              .symbolism,
                                              .literature,
                                              .dyeingCraft,
                                              .colorDistinction])
        config.re.add()
        Defaults().set(revision, for: AppKey.traditionalDetailConfigRevision)
    }
}
