//
//  Content.swift
//  SearchFeedbackExample
//
//  Created by Jasdeep Saini on 5/10/20.
//  Copyright © 2020 Jasdeep Saini. All rights reserved.
//

import SwiftUI
import CombineFeedbackUI

extension Feature.Search {
    struct Content: View {
        @ObservedObject var context: Context<State, Event>

        init(context: Context<State, Event>) {
            self.context = context
        }

        private var contentView: some View {
            switch context.status {
            case .idle:
                return AnyView(
                    VStack {
                        Spacer()
                        Text("Search a List of Movies")
                        Spacer()
                    }
                )
                
            case .loaded:
                return AnyView(resultsView(for: context.results))

            case .loading:
                return AnyView(
                    VStack {
                        Spacer()
                        ZStack(alignment: .center) {
                            Activity(style: .medium)
                        }
                        Spacer()
                    }
                )

            case .loadingFailed(let error):
                return AnyView(
                    VStack {
                        Spacer()
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                        Spacer()
                    }
                )

            case .noResults:
                return AnyView(
                    VStack {
                        Spacer()
                        Text("No Results")
                        Spacer()
                    }
                )
            }
        }

        private func resultsView(for results: [Movie]) -> some View {
            List {
                ForEach(results) {
                    Text($0.title)
                }
            }
        }

        @ViewBuilder
        var body: some View {
            VStack {
                HStack {
                    TextField("Search",
                              text: context.binding(for: \.searchString, event: Feature.Search.Event.userEnteredSearch)
                    )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

                contentView
            }
            .keyboardAdaptor()
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        Widget(
            store: Feature.Search.SearchViewModel(),
            content: Feature.Search.Content.init(context:)
        )
    }
}
