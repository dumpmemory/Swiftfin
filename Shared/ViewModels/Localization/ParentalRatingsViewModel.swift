//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI

final class ParentalRatingsViewModel: BaseFetchViewModel<[ParentalRating]> {

    // MARK: - getValue

    override func getValue() async throws -> [ParentalRating] {
        let request = Paths.getParentalRatings
        let response = try await userSession.client.send(request)

        return response.value
    }
}
