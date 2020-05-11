//
//  SearchViewModel.swift
//  SearchFeedbackExample
//
//  Created by Jasdeep Saini on 5/10/20.
//  Copyright © 2020 Jasdeep Saini. All rights reserved.
//

import Foundation
import CombineFeedback
import CombineFeedbackUI
import Combine

struct Feature {
    enum Search { }
}

extension Feature.Search {
    enum Status: Equatable {
        case idle
        case loading
        case loaded
        case noResults
        case loadingFailed(Error)

        public static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case(.idle, .idle),
                (.loading, .loading),
                (.loaded, .loaded),
                (.noResults, .noResults),
                (.loadingFailed, .loadingFailed): // Ignoring the actual error for now
                return true

            case(.idle, _),
                (.loading, _),
                (.loaded, _),
                (.noResults, _),
                (.loadingFailed, _): // Ignoring the actual error for now
                return false
            }
        }
    }

    enum Event {
        case userEnteredSearch(String)
        case loadedResults([Movie])
        case loadingFailed(Error)
    }

    struct State {
        var status: Status = .idle
        var searchString = ""
        var results = [Movie]()

        static func reducer() -> Reducer<State, Event> {
            Reducer { state, event in
                switch event {
                case .userEnteredSearch(let searchString):
                    state.searchString = searchString

                    if searchString.count == 0 {
                        state.status = .idle
                    } else {
                        state.status = .loading
                    }

                case .loadedResults(let results):
                    state.results = results

                    if results.count == 0 {
                        state.status = .noResults
                    } else {
                        state.status = .loaded
                    }

                case .loadingFailed(let error):
                    state.status = .loadingFailed(error)
                }
            }
        }
    }

    class SearchViewModel: Store<State, Event> {
        init() {
            super.init(
                initial: State(),
                feedbacks: [
                    SearchViewModel.whenUserEnteredSearchString()
                ],
                reducer: State.reducer()
            )
        }

        private static func whenUserEnteredSearchString() -> Feedback<State, Event> {
            Feedback.lensing(event: { event -> String? in
                if case let Event.userEnteredSearch(searchString) = event {
                    return searchString
                }

                return nil
            }) { searchString -> AnyPublisher<Event, Never> in
                MoviesFetcher()
                    .filteredMovies(for: searchString)
                    .map { movieFetcherResult -> Event in
                        switch movieFetcherResult {
                        case .success(let movies):
                            return Event.loadedResults(movies)

                        case .failure(let error):
                            return Event.loadingFailed(error)
                        }
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
}
