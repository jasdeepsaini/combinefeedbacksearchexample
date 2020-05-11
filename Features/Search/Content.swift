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

        private var contentView: some View {
            switch context.status {
            case .idle:
                return centeredTextView(withText: "Search a List of Movies", foregroundColor: .gray)

            case .loaded:
                return listView(for: context.results)

            case .loading:
                return loadingView()

            case .loadingFailed:
                return centeredTextView(withText: "Loading Failed!", foregroundColor: .red)

            case .noResults:
                return centeredTextView(withText: "No Results", foregroundColor: .gray)
            }
        }

        private func listView(for results: [Movie]) -> AnyView {
            AnyView(
                List {
                    ForEach(results) {
                        Text($0.title)
                    }
                }
            )
        }

        private func centeredTextView(withText text: String, foregroundColor: Color) -> AnyView {
            AnyView(
                VStack {
                    Spacer()
                    Text(text)
                        .foregroundColor(foregroundColor)
                    Spacer()
                }
            )
        }

        private func loadingView() -> AnyView {
            AnyView(
                VStack {
                    Spacer()
                    ZStack(alignment: .center) {
                        Activity(style: .medium)
                    }
                    Spacer()
                }
            )
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
