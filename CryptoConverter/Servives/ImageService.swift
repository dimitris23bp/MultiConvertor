//
//  ImageService.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import Foundation

public actor ImageService {

    // MARK: - Public Types

    public enum Resolution: Int, Codable, CaseIterable, Sendable {
        case px16 = 16
        case px32 = 32
        case px64 = 64
        case px128 = 128

        var stringValue: String { String(rawValue) }
    }

    public enum Mode: String, Codable, CaseIterable, Sendable {
        case single
        case multiple
    }

    public struct Parser: Codable, Sendable {
        public struct Options: Codable, Sendable {
            public var removeNumbers: Bool
            public init(removeNumbers: Bool = true) { self.removeNumbers = removeNumbers }
        }
        public var enable: Bool
        public var options: Options
        public init(enable: Bool = true, options: Options = .init()) {
            self.enable = enable
            self.options = options
        }
        public static let `default` = Parser()
    }

    public struct LogoItem: Hashable, Sendable {
        public let symbol: String
        public let name: String
        public let url: URL
        public let rank: Int?
    }

    public enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case requestFailed(statusCode: Int)
        case decodingFailed(Swift.Error)
        case network(Swift.Error)
        case emptyResponse

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL for logos endpoint."
            case .requestFailed(let statusCode):
                return "Request failed with status code \(statusCode)."
            case .decodingFailed(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .network(let error):
                return "Network error: \(error.localizedDescription)"
            case .emptyResponse:
                return "The server returned an empty response."
            }
        }
    }

    // MARK: - Private DTOs

    private struct LogosRequestPayload: Encodable {
        let symbols: [String]
        let resolution: String
        let mode: Mode
        let parser: Parser
    }

    private struct LogoResponse: Decodable {
        let png: URL
        let rank: Int?
        let symbol: String
        let name: String
    }

    // MARK: - Properties

    private let endpoint = URL(string: "https://logos.tradeloop.app/api/getLogos")

    public init() {}

    // MARK: - Public API

    /// Fetch a list of logo items (symbol, name, rank, url) for the provided symbols.
    /// - Parameters:
    ///   - symbols: Any strings are accepted; the server can parse them based on the parser options.
    ///   - resolution: One of 16, 32, 64, 128.
    ///   - mode: Either `.single` or `.multiple`.
    ///   - parser: Controls server-side parsing (e.g., removing numbers).
    /// - Returns: An array of `LogoItem`.
    public func fetchLogos(
        for symbols: [String],
        resolution: Resolution = .px128,
        mode: Mode = .single,
        parser: Parser = .default
    ) async throws -> [LogoItem] {
        guard let url = endpoint else { throw Error.invalidURL }

        let payload = LogosRequestPayload(
            symbols: symbols,
            resolution: resolution.stringValue,
            mode: mode,
            parser: parser
        )
		print("Payload is: \(payload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(payload)
        } catch {
			print("Network error")
            throw Error.network(error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
			print("Network error")
            throw Error.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
			print("Failed Request")
            throw Error.requestFailed(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
			print("Failed Request with status code: \(http.statusCode)")

            throw Error.requestFailed(statusCode: http.statusCode)
        }
        guard !data.isEmpty else {
			print("Empty Response")
            throw Error.emptyResponse
        }

        do {
            let dtos = try JSONDecoder().decode([LogoResponse].self, from: data)
            let items = dtos.map { dto in
                LogoItem(symbol: dto.symbol, name: dto.name, url: dto.png, rank: dto.rank)
            }
            return items
        } catch {
            throw Error.decodingFailed(error)
        }
    }

    /// Fetch the URL for a single symbol. 
    public func fetchLogoURL(
        for symbol: String,
        resolution: Resolution = .px64,
        parser: Parser = .default
	) async throws -> URL? {

		print("FetchLogoURL for \(symbol)")
        let items = try await fetchLogos(for: [symbol], resolution: resolution, mode: .single, parser: parser)
		print("FetchLogoURL - items are: \(items)")

		if let url = items.first?.url {
            return url
		}

		print("There is no image for \(symbol)")
		return nil
    }

    /// Fetch a dictionary mapping response symbols to logo URLs.
    public func fetchLogoURLs(
        for symbols: [String],
        resolution: Resolution = .px128,
        mode: Mode = .single,
        parser: Parser = .default
    ) async throws -> [String: URL] {
//		print("FetchLogoURLs started with symbols: \(symbols)")
        let items = try await fetchLogos(for: symbols, resolution: resolution, mode: mode, parser: parser)
//		print("FetchLogoURLs - items are: \(items)")
        var dict: [String: URL] = [:]
        for item in items {
            dict[item.symbol] = item.url
        }
        return dict
    }
}
