//
//  Models.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Value types + enums used across the app.
//

import SwiftUI

// MARK: - App routing

enum AppPhase: Equatable {
    case onboarding
    case paywall
    case verseShare
    case main
}

enum AppModal: Identifiable {
    case dailyPlan
    case journey

    var id: String {
        switch self {
        case .dailyPlan: return "dailyPlan"
        case .journey: return "journey"
        }
    }
}

// MARK: - Onboarding answers

/// Q1 — "How would you describe your relationship with faith?"
enum FaithLevel: String, CaseIterable, Identifiable, Codable {
    case curious   = "Not religious, just curious"
    case notActive = "Believe, but not very active"
    case practicing = "Practicing regularly"
    case central   = "Faith is central to my life"
    var id: String { rawValue }

    /// Haven's warm acknowledgement after the choice.
    var response: String {
        switch self {
        case .curious:   return "Curiosity is where so many journeys begin — no pressure here."
        case .notActive: return "Belief is a seed. Even quietly held, it's still alive in you."
        case .practicing: return "There's real strength in showing up for your faith, day after day."
        case .central:   return "What a gift, to have faith at the very center of your life."
        }
    }
}

/// Q2 — "What's making you want to explore faith more right now?"
enum Motivation: String, CaseIterable, Identifiable, Codable {
    case meaning  = "I'm searching for meaning or purpose"
    case hard     = "I'm walking through something hard"
    case curious  = "I'm curious what faith could look like for me"
    case admire   = "Someone close to me has a faith I admire"
    case missing  = "I feel like something's missing"
    var id: String { rawValue }

    var response: String {
        switch self {
        case .meaning: return "That search matters more than you know."
        case .hard:    return "You don't have to carry the hard things alone."
        case .curious: return "Wondering is the first step of every faith."
        case .admire:  return "The faith we admire in others is often already stirring in us."
        case .missing: return "That ache for something more is worth listening to."
        }
    }
}

/// Daily-plan mood slider positions.
enum Mood: Int, CaseIterable, Identifiable {
    case low = 0, downcast, neutral, hopeful, joyful
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .low: return "low"; case .downcast: return "downcast"
        case .neutral: return "neutral"; case .hopeful: return "hopeful"; case .joyful: return "joyful"
        }
    }
}

// MARK: - Scripture

struct Verse: Hashable {
    let text: String
    let reference: String
}

enum Testament: String { case old = "Old Testament", new = "New Testament" }

struct BibleBook: Identifiable, Hashable {
    let name: String
    let abbreviation: String
    let chapters: Int
    let testament: Testament
    var id: String { name }
}

/// A single chapter's verses, keyed by verse number.
struct Chapter: Hashable {
    let book: String
    let number: Int
    let verses: [String]   // verses[0] == verse 1
}

// MARK: - Journey (streak map → postcards)

struct JourneyStop: Identifiable, Hashable {
    let name: String
    let verse: String
    let reference: String
    let artwork: HavenArtwork
    let streaksRequired: Int
    var id: String { name }
}

// MARK: - Listen library

struct Story: Identifiable, Hashable {
    let title: String
    let reference: String
    let artwork: HavenArtwork
    let durationSeconds: Int
    /// Narration split into sentences for karaoke-style highlighting.
    let narration: [String]
    var id: String { title }
}

struct LibrarySection: Identifiable, Hashable {
    let title: String
    let subtitle: String
    let stories: [Story]
    var id: String { title }
}

struct LibraryCollection: Identifiable, Hashable {
    let title: String
    let artwork: HavenArtwork
    let sections: [LibrarySection]
    var id: String { title }
}

// MARK: - Chat

enum ChatRole: String, Codable { case haven, user }

struct ChatMessage: Identifiable, Hashable, Codable {
    var id = UUID()
    let role: ChatRole
    var text: String
    var verseRef: String? = nil
}

struct ChatTopic: Identifiable, Hashable {
    let title: String
    let artwork: HavenArtwork
    /// Suggested opening prompts shown as chips.
    let prompts: [String]
    var id: String { title }
}

struct Conversation: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String        // e.g. "Today"
    var messages: [ChatMessage]
}

// MARK: - Daily plan / devotional

struct Devotional: Hashable {
    let topic: String           // "Daily Bread"
    let minutes: Int
    let artwork: HavenArtwork
    let body: String
    let prayer: String
}
