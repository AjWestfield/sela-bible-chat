//
//  DebugRoute.swift
//  Bible Chat  ·  "Haven" recreation
//
//  DEBUG-only deep-linking via environment variables so any screen can be
//  launched directly for visual QA. Compiled out of Release builds.
//
//  Examples (passed as launch env):
//    HAVEN_SCREEN = onboarding | paywall | verseShare | main | mainReview
//    HAVEN_OB     = carousel | notifications | conversation | prayer | personalized
//    HAVEN_CAROUSEL_PAGE = 0...4
//    HAVEN_TAB    = home | listen | read
//    HAVEN_MODAL  = dailyplan | chat | player
//

import Foundation

#if DEBUG
enum DebugRoute {
    private static var env: [String: String] { ProcessInfo.processInfo.environment }
    static var screen: String? { env["HAVEN_SCREEN"] }
    static var obStep: String? { env["HAVEN_OB"] }
    static var carouselPage: String? { env["HAVEN_CAROUSEL_PAGE"] }
    static var tab: String?    { env["HAVEN_TAB"] }
    static var modal: String?  { env["HAVEN_MODAL"] }
    static var postcardStage: String? { env["HAVEN_POSTCARD"] } // streak | congrats | reveal
    static var settings: String? { env["HAVEN_SETTINGS"] }      // menu | editinfo | preferences | bibleversion | charm | notifications
    static var dark: Bool { env["HAVEN_DARK"] == "1" }
    static var active: Bool { screen != nil || obStep != nil || carouselPage != nil || tab != nil || modal != nil || settings != nil }
}
#endif
