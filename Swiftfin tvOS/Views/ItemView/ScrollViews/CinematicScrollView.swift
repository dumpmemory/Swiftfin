//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension ItemView {

    struct CinematicScrollView<Content: View>: ScrollContainerView {

        @ObservedObject
        private var viewModel: ItemViewModel

        private let content: Content

        init(
            viewModel: ItemViewModel,
            content: @escaping () -> Content
        ) {
            self.viewModel = viewModel
            self.content = content()
        }

        var body: some View {
            ZStack {
                if viewModel.item.type == .episode {
                    ImageView(viewModel.item.imageSource(.primary, maxWidth: 1920))
                } else {
                    ImageView(viewModel.item.imageSource(.backdrop, maxWidth: 1920))
                }

                ScrollView(.vertical, showsIndicators: false) {
                    content
                        .background {
                            BlurView(style: .dark)
                                .mask {
                                    VStack(spacing: 0) {
                                        LinearGradient(gradient: Gradient(stops: [
                                            .init(color: .white, location: 0),
                                            .init(color: .white.opacity(0.7), location: 0.4),
                                            .init(color: .white.opacity(0), location: 1),
                                        ]), startPoint: .bottom, endPoint: .top)
                                            .frame(height: UIScreen.main.bounds.height - 150)

                                        Color.white
                                    }
                                }
                        }
                }
            }
            .ignoresSafeArea()
        }
    }
}

extension ItemView {

    struct CinematicHeaderView: View {

        enum CinematicHeaderFocusLayer: Hashable {
            case top
            case playButton
            case actionButtons
        }

        @StoredValue(.User.itemViewAttributes)
        private var attributes

        @Router
        private var router
        @ObservedObject
        var viewModel: ItemViewModel
        @FocusState
        private var focusedLayer: CinematicHeaderFocusLayer?

        var body: some View {
            VStack(alignment: .leading) {

                Color.clear
                    .focusable()
                    .focused($focusedLayer, equals: .top)

                HStack(alignment: .bottom) {

                    VStack(alignment: .leading, spacing: 20) {

                        ImageView(viewModel.item.imageSource(
                            .logo,
                            maxWidth: UIScreen.main.bounds.width * 0.4,
                            maxHeight: 250
                        ))
                        .placeholder { _ in
                            EmptyView()
                        }
                        .failure {
                            Text(viewModel.item.displayTitle)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                        }
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom)
                        .frame(maxHeight: 250, alignment: .bottomLeading)

                        if let tagline = viewModel.item.taglines?.first {
                            Text(tagline)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                        }

                        Text(viewModel.item.overview ?? L10n.noOverviewAvailable)
                            .font(.subheadline)
                            .lineLimit(3)

                        HStack {

                            DotHStack {
                                if let firstGenre = viewModel.item.genres?.first {
                                    Text(firstGenre)
                                }

                                if let premiereYear = viewModel.item.premiereDateYear {
                                    Text(premiereYear)
                                }

                                if let playButtonitem = viewModel.playButtonItem, let runtime = playButtonitem.runTimeLabel {
                                    Text(runtime)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(Color(UIColor.lightGray))

                            ItemView.AttributesHStack(
                                attributes: attributes,
                                viewModel: viewModel
                            )
                        }
                    }

                    Spacer()

                    VStack {
                        if viewModel.presentPlayButton {
                            ItemView.PlayButton(viewModel: viewModel)
                                .focused($focusedLayer, equals: .playButton)
                        }

                        ItemView.ActionButtonHStack(viewModel: viewModel)
                            .focused($focusedLayer, equals: .actionButtons)
                            .frame(width: 440)
                    }
                    .frame(width: 450)
                    .padding(.leading, 150)
                }
            }
            .padding(.horizontal, 50)
            .onChange(of: focusedLayer) { _, layer in
                if layer == .top {
                    if viewModel.presentPlayButton {
                        focusedLayer = .playButton
                    } else {
                        focusedLayer = .actionButtons
                    }
                }
            }
        }
    }
}
