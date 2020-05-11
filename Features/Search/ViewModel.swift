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
        case loadingFailed
    }

    enum Event {
        // User Initiated Events
        case userEnteredSearchString(String)

        // Other Events
        case loadedResults([Movie])
        case loadingFailed
    }

    struct State {
        var status: Status = .idle
        var searchString = ""
        var results = [Movie]()

        static func reducer() -> Reducer<State, Event> {
            Reducer { state, event in
                switch event {
                case .userEnteredSearchString(let searchString):
                    state.searchString = searchString

                    if searchString.count == 0 {
                        state.status = .idle
                    } else {
                        state.status = .loading
                    }

                case .loadedResults(let results):
                    state.results = results

                    if results.count == 0 {
                        if state.searchString.isEmpty {
                            state.status = .idle
                        } else {
                            state.status = .noResults
                        }
                    } else {
                        state.status = .loaded
                    }

                case .loadingFailed:
                    state.status = .loadingFailed
                }
            }
        }
    }

    class SearchViewModel: Store<State, Event> {
        init() {
            super.init(
                initial: State(),
                feedbacks: [
                    SearchViewModel.whenUserEntersSearchString()
                ],
                reducer: State.reducer()
            )
        }

        private static func whenUserEntersSearchString() -> Feedback<State, Event> {
            Feedback.lensing(state: { state -> String? in
                if state.status == .loading {
                    return state.searchString
                }

                return nil
            }) { searchString -> AnyPublisher<Event, Never> in
                MoviesFetcher()
                    .filteredMovies(for: searchString)
                    .map { movieFetcherResult -> Event in
                        switch movieFetcherResult {
                        case .success(let movies):
                            return Event.loadedResults(movies)

                        case .failure:
                            return Event.loadingFailed
                        }
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
}
