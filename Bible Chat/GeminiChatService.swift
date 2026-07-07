//
//  GeminiChatService.swift
//  Bible Chat
//
//  Minimal Gemini API client for Sela's chat experience.
//

import Foundation

struct GeminiChatService {
    private let apiKey: String
    private let model: String
    private let session: URLSession

    init(
        apiKey: String = GeminiConfig.apiKey,
        model: String = GeminiConfig.model,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func reply(to messages: [ChatMessage], appState: AppState) async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiChatError.missingAPIKey }

        let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(makeRequest(messages: messages, appState: appState))

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GeminiChatError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let apiError = try? JSONDecoder().decode(GeminiErrorEnvelope.self, from: data)
            throw GeminiChatError.api(statusCode: http.statusCode, message: apiError?.error.message)
        }

        let decoded = try JSONDecoder().decode(GeminiGenerateContentResponse.self, from: data)
        guard let candidate = decoded.candidates.first else { throw GeminiChatError.emptyResponse }

        let text = candidate
            .content
            .parts
            .compactMap(\.text)
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { throw GeminiChatError.emptyResponse }
        return appendGroundingSources(to: text, metadata: candidate.groundingMetadata)
    }

    private func makeRequest(messages: [ChatMessage], appState: AppState) -> GeminiGenerateContentRequest {
        let contents = messages.map { message in
            GeminiContent(
                role: message.role == .user ? "user" : "model",
                parts: [GeminiPart(text: message.text)]
            )
        }

        return GeminiGenerateContentRequest(
            systemInstruction: GeminiContent(
                role: nil,
                parts: [GeminiPart(text: systemPrompt(appState: appState))]
            ),
            contents: contents,
            generationConfig: GeminiGenerationConfig(
                temperature: 0.72,
                topP: 0.9,
                maxOutputTokens: 700
            ),
            tools: [.googleSearch]
        )
    }

    private func systemPrompt(appState: AppState) -> String {
        """
        You are \(Brand.companionName), the AI chat companion inside \(Brand.productLine).
        Offer warm, biblically grounded guidance in a calm, conversational voice.
        Keep replies concise: usually 2 to 4 short paragraphs.
        When helpful, include one relevant Bible reference and a small prayer or reflection step.
        Do not invent exact Bible quotations. If you are uncertain, paraphrase and name the reference.
        If you are not highly confident, or if the user's question depends on current facts, recent events, laws, prices, schedules, public figures, product details, or other information that may have changed, use Google Search grounding before answering.
        When you use search, answer from the grounded results and make clear what you verified.
        Respect the user's faith background: \(appState.faithLevel?.rawValue ?? "unknown").
        The user's current motivation is: \(appState.motivation?.rawValue ?? "unknown").
        The user's named challenge is: \(appState.challenge.isEmpty ? "unknown" : appState.challenge).
        If the user mentions self-harm, abuse, or immediate danger, respond with care and encourage contacting emergency services or a trusted person right away.
        """
    }

    private func appendGroundingSources(to text: String, metadata: GeminiGroundingMetadata?) -> String {
        let sources = metadata?
            .groundingChunks?
            .compactMap(\.web)
            .compactMap { web -> (title: String, uri: String)? in
                guard let uri = web.uri, !uri.isEmpty else { return nil }
                let title = web.title?.isEmpty == false ? web.title! : uri
                return (title, uri)
            }
            .uniqueByURI()
            .prefix(3) ?? []

        guard !sources.isEmpty else { return text }

        let sourceLines = sources
            .enumerated()
            .map { index, source in "[\(index + 1)] \(source.title) - \(source.uri)" }
            .joined(separator: "\n")

        return "\(text)\n\nSources:\n\(sourceLines)"
    }
}

enum GeminiConfig {
    static var model: String {
        value(named: "GeminiModel", environmentKeys: ["GEMINI_MODEL"])
            ?? "gemini-3.1-flash-lite"
    }

    static var apiKey: String {
        value(
            named: "GeminiAPIKey",
            environmentKeys: ["GEMINI_API_KEY", "GOOGLE_API_KEY", "GOOGLE_GENAI_API_KEY"]
        ) ?? ""
    }

    private static func value(named infoKey: String, environmentKeys: [String]) -> String? {
        if let value = Bundle.main.object(forInfoDictionaryKey: infoKey) as? String,
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }

        for key in environmentKeys {
            if let value = ProcessInfo.processInfo.environment[key],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
        }

        return nil
    }
}

enum GeminiChatError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case api(statusCode: Int, message: String?)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Gemini is not configured yet. Add a Gemini API key with the GEMINI_API_KEY environment variable or the GeminiAPIKey build setting."
        case .invalidResponse:
            "Gemini returned an invalid response."
        case .api(let statusCode, let message):
            "Gemini request failed with HTTP \(statusCode): \(message ?? "No error message returned.")"
        case .emptyResponse:
            "Gemini returned an empty response."
        }
    }
}

private struct GeminiGenerateContentRequest: Encodable {
    let systemInstruction: GeminiContent
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
    let tools: [GeminiTool]
}

private struct GeminiGenerationConfig: Encodable {
    let temperature: Double
    let topP: Double
    let maxOutputTokens: Int
}

private struct GeminiContent: Codable {
    let role: String?
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String?
}

private struct GeminiGenerateContentResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiContent
    let groundingMetadata: GeminiGroundingMetadata?
}

private struct GeminiTool: Encodable {
    static let googleSearch = GeminiTool(googleSearch: GeminiGoogleSearch())

    let googleSearch: GeminiGoogleSearch

    enum CodingKeys: String, CodingKey {
        case googleSearch = "google_search"
    }
}

private struct GeminiGoogleSearch: Encodable {}

private struct GeminiGroundingMetadata: Decodable {
    let groundingChunks: [GeminiGroundingChunk]?
}

private struct GeminiGroundingChunk: Decodable {
    let web: GeminiGroundingWeb?
}

private struct GeminiGroundingWeb: Decodable {
    let uri: String?
    let title: String?
}

private struct GeminiErrorEnvelope: Decodable {
    let error: GeminiAPIError
}

private struct GeminiAPIError: Decodable {
    let message: String
}

private extension Array where Element == (title: String, uri: String) {
    func uniqueByURI() -> [(title: String, uri: String)] {
        var seen = Set<String>()
        return filter { source in
            if seen.contains(source.uri) { return false }
            seen.insert(source.uri)
            return true
        }
    }
}
