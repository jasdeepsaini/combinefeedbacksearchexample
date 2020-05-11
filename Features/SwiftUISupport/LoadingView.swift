//
//  LoadingView.swift
//  SearchFeedbackExample
//
//  Created by Jasdeep Saini on 5/11/20.
//  Copyright © 2020 Jasdeep Saini. All rights reserved.
//

import SwiftUI

struct Activity: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView

    var style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<Activity>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Activity>) {}
}

#if DEBUG
struct Activity_Previews : PreviewProvider {
    static var previews: some View {
        Activity(style: .medium)
    }
}
#endif
