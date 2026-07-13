protocol UserServicing {
    func currentUserName() -> String
}

final class UserService: UserServicing {
    func currentUserName() -> String { "Гость" }
}
