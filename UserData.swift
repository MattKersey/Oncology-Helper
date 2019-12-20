//
//  UserData.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject {
    @Published var appointments = appointmentData
}
