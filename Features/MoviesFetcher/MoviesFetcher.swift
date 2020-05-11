//
//  MoviesFetcher.swift
//  SearchFeedbackExample
//
//  Created by Jasdeep Saini on 5/11/20.
//  Copyright © 2020 Jasdeep Saini. All rights reserved.
//

import Foundation
import Combine

struct Movie: Identifiable {
    let id = UUID()
    let title: String
}

class MoviesFetcher {
    typealias MovieFetcherResult = Result<[Movie], Error>
    private var movies: [Movie]

    init() {
        do {
            if let path = Bundle.main.path(forResource: "Movies", ofType: "csv") {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                self.movies = data.components(separatedBy: CharacterSet.newlines)
                    .map { Movie(title: $0) }
            } else {
                assertionFailure("Couldn't parse Movies.csv")
                movies = []
            }
        } catch {
            assertionFailure("Couldn't parse Movies.csv")
            movies = []
        }
    }

    func filteredMovies(for searchString: String) -> AnyPublisher<MovieFetcherResult, Never> {
        let randomInt = Int.random(in: 0..<100)

        if randomInt < 5 {
            let result = MovieFetcherResult.failure(NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Loading Failed"]))
            return Just(result).eraseToAnyPublisher()
        } else {
            let filteredMovies = movies.filter { $0.title.contains(searchString) }
            return Just(MovieFetcherResult.success(filteredMovies))
                .delay(for: .init(integerLiteral: 1.0), scheduler: RunLoop.main)    // Simulate call to API
                .eraseToAnyPublisher()
        }
    }
}
