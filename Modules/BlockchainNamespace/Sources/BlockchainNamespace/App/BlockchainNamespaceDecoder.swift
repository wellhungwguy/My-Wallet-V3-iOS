// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding

open class BlockchainNamespaceDecoder: AnyDecoder {

    var context: Tag.Context = [:]
    var language: Language {
        userInfo[.language] as? Language ?? Language.root.language
    }

    override public func convert<T>(_ any: Any, to type: T.Type) throws -> Any? {
        switch (any, type) {
        case (let tag as Tag, is Tag.Reference.Type):
            return tag.ref(to: context)
        case (let ref as Tag.Reference, is Tag.Type):
            return ref.tag
        case (let id as L, is Tag.Type):
            return id[]
        case (let id as L, is Tag.Reference.Type):
            return id[].ref(to: context)
        case (let string as String, is Tag.Type):
            return try Tag(id: string, in: language)
        case (let string as String, is Tag.Reference.Type):
            return try Tag.Reference(id: string, in: language)
        default:
            return try super.convert(any, to: type)
        }
    }
}
