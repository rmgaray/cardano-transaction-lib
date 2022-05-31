{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "cardano-transaction-lib"
, dependencies =
  [ "aeson"
  , "aff"
  , "aff-promise"
  , "affjax"
  , "arraybuffer-types"
  , "arrays"
  , "bifunctors"
  , "bigints"
  , "checked-exceptions"
  , "console"
  , "const"
  , "control"
  , "debug"
  , "effect"
  , "either"
  , "encoding"
  , "enums"
  , "exceptions"
  , "foldable-traversable"
  , "foreign-object"
  , "http-methods"
  , "identity"
  , "integers"
  , "js-date"
  , "lattice"
  , "lists"
  , "maybe"
  , "medea"
  , "media-types"
  , "monad-logger"
  , "mote"
  , "newtype"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-fs-aff"
  , "node-path"
  , "nonempty"
  , "ordered-collections"
  , "partial"
  , "prelude"
  , "profunctor"
  , "profunctor-lenses"
  , "quickcheck"
  , "quickcheck-laws"
  , "rationals"
  , "record"
  , "refs"
  , "spec"
  , "strings"
  , "tailrec"
  , "these"
  , "transformers"
  , "tuples"
  , "typelevel"
  , "typelevel-prelude"
  , "uint"
  , "undefined"
  , "unfoldable"
  , "untagged-union"
  , "variant"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs", "examples/**/*.purs" ]
}
