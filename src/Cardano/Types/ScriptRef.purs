module Cardano.Types.ScriptRef
  ( ScriptRef(NativeScriptRef, PlutusScriptRef)
  , scriptRefHash
  ) where

import Prelude

import Aeson
  ( class EncodeAeson
  , encodeAeson'
  )
import Hashing (plutusScriptHash)
import Helpers (encodeTagged')
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(Just))
import Data.Show.Generic (genericShow)
import Cardano.Types.NativeScript (NativeScript)
import Serialization.Hash (ScriptHash, nativeScriptHash)
import Serialization.NativeScript (convertNativeScript)
import Types.Scripts (PlutusScript)

data ScriptRef = NativeScriptRef NativeScript | PlutusScriptRef PlutusScript

derive instance Eq ScriptRef
derive instance Generic ScriptRef _

instance Show ScriptRef where
  show = genericShow

instance EncodeAeson ScriptRef where
  encodeAeson' = case _ of
    NativeScriptRef r -> encodeAeson' $ encodeTagged' "NativeScriptRef" r
    PlutusScriptRef r -> encodeAeson' $ encodeTagged' "PlutusScriptRef" r

scriptRefHash :: ScriptRef -> Maybe ScriptHash
scriptRefHash (PlutusScriptRef plutusScript) =
  Just (plutusScriptHash plutusScript)
scriptRefHash (NativeScriptRef nativeScript) =
  nativeScriptHash <$> convertNativeScript nativeScript
