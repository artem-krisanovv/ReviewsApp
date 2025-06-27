struct UserModel {
    let id: Int
    let avatar_url: String
    let first_name: String
    let last_name: String
    
    static let empty = UserModel(
        id: 0,
        avatar_url: "",
        first_name: "",
        last_name: ""
    )
}

extension UserModel {
    var avatarURL: String { avatar_url }
    var firstName: String { first_name }
    var lastName:  String { last_name  }
}

extension UserDto {
    var model: UserModel {
        UserModel(
            id: id,
            avatar_url: avatar_url,
            first_name: first_name,
            last_name: last_name
        )
    }
}
