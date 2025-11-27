//
//  NetworkService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(url: String) async throws -> T
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw AppError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = APIConstants.timeoutInterval
        request.httpMethod = "GET"
        
        request.setValue("GitHubUsers/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch let decodingError as DecodingError {
                    let errorMessage = self.describe(decodingError)
                    throw AppError.decodingError(errorMessage)
                } catch {
                    throw AppError.decodingError(error.localizedDescription)
                }
            case 404:
                throw AppError.notFound
            case 401:
                if let errorData = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data),
                   let message = errorData.message {
                    throw AppError.networkError("Unauthorized: \(message)")
                }
                throw AppError.unauthorized
            case 403:
                if let errorData = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data),
                   let message = errorData.message {
                    if message.lowercased().contains("rate limit") || message.lowercased().contains("api rate limit") {
                        throw AppError.networkError("Rate limit exceeded. Please try again later.")
                    }
                    throw AppError.networkError("Forbidden: \(message)")
                }
                throw AppError.networkError("Forbidden: Check User-Agent header and request format")
            case 422:
                if let errorData = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data),
                   let message = errorData.message {
                    throw AppError.networkError("Validation failed: \(message)")
                }
                throw AppError.networkError("Validation failed")
            case 429:
                throw AppError.networkError("Rate limit exceeded. Please try again later.")
            default:
                if let errorData = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data),
                   let message = errorData.message {
                    throw AppError.serverError(httpResponse.statusCode)
                }
                throw AppError.serverError(httpResponse.statusCode)
            }
        } catch let error as AppError {
            throw error
        } catch let urlError as URLError {
            // Обработка специфичных ошибок URL
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw AppError.networkError("No internet connection")
            case .timedOut:
                throw AppError.networkError("Request timed out")
            default:
                throw AppError.networkError(urlError.localizedDescription)
            }
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }
    }
    
    private func describe(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
        case .valueNotFound(let type, let context):
            return "Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error: \(error.localizedDescription)"
        }
    }
    
    private func getCodingPath(from error: DecodingError) -> String {
        switch error {
        case .typeMismatch(_, let context):
            return context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
        case .valueNotFound(_, let context):
            return context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
        case .keyNotFound(let key, let context):
            return (context.codingPath.map { $0.stringValue } + [key.stringValue]).joined(separator: " -> ")
        case .dataCorrupted(let context):
            return context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
        @unknown default:
            return "unknown"
        }
    }
}

private struct GitHubErrorResponse: Codable {
    let message: String?
    let documentationURL: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case documentationURL = "documentation_url"
    }
}

