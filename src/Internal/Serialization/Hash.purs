module Ctl.Internal.Serialization.Hash
  ( Ed25519KeyHash
  , ScriptHash
  , VRFKeyHash
  , ed25519KeyHashFromBech32
  , ed25519KeyHashFromBytes
  , ed25519KeyHashToBech32
  , ed25519KeyHashToBech32Unsafe
  , ed25519KeyHashToBytes
  , nativeScriptHash
  , scriptHashFromBech32
  , scriptHashFromBytes
  , scriptHashToBech32
  , scriptHashToBech32Unsafe
  , scriptHashToBytes
  ) where

import Prelude

import Aeson
  ( class DecodeAeson
  , class EncodeAeson
  , JsonDecodeError(TypeMismatch)
  , caseAesonString
  , encodeAeson
  )
import Ctl.Internal.FfiHelpers (MaybeFfiHelper, maybeFfiHelper)
import Ctl.Internal.FromData (class FromData)
import Ctl.Internal.Metadata.FromMetadata (class FromMetadata)
import Ctl.Internal.Metadata.ToMetadata (class ToMetadata, toMetadata)
import Ctl.Internal.Serialization.Types (NativeScript)
import Ctl.Internal.ToData (class ToData, toData)
import Ctl.Internal.Types.Aliases (Bech32String)
import Ctl.Internal.Types.ByteArray
  ( ByteArray
  , byteArrayFromIntArrayUnsafe
  , byteArrayToHex
  , hexToByteArray
  )
import Ctl.Internal.Types.PlutusData (PlutusData(Bytes))
import Ctl.Internal.Types.RawBytes (RawBytes, rawBytesToHex)
import Ctl.Internal.Types.TransactionMetadata (TransactionMetadatum(Bytes)) as Metadata
import Data.Either (Either(Left, Right), note)
import Data.Function (on)
import Data.Maybe (Maybe(Nothing, Just), fromJust, maybe)
import Data.Newtype (unwrap, wrap)
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck.Arbitrary (class Arbitrary)
import Test.QuickCheck.Gen (chooseInt, vectorOf)

-- We can't use ToBytes class here, because of cyclic dependencies
-- | Encodes the hash to `CborBytes`
foreign import hashToBytes :: forall (a :: Type). a -> ByteArray

-- We can't use FromBytes class here, because of cyclic dependencies
-- | Decodes `CborBytes` to the hash
foreign import hashFromBytes
  :: forall (a :: Type)
   . String
  -> MaybeFfiHelper
  -> ByteArray
  -> Maybe a

foreign import nativeScriptHash :: NativeScript -> ScriptHash

foreign import hashToBech32Unsafe
  :: forall (a :: Type)
   . String
  -> a
  -> Bech32String

foreign import hashToBech32Impl
  :: forall (a :: Type)
   . MaybeFfiHelper
  -> String
  -> a
  -> Maybe Bech32String

foreign import _ed25519KeyHashFromBech32Impl
  :: MaybeFfiHelper
  -> Bech32String
  -> Maybe Ed25519KeyHash

foreign import _scriptHashFromBech32Impl
  :: MaybeFfiHelper
  -> Bech32String
  -> Maybe ScriptHash

-- | PubKeyHash and StakeKeyHash refers to blake2b-224 hash digests of Ed25519
-- | verification keys
foreign import data Ed25519KeyHash :: Type

instance Eq Ed25519KeyHash where
  eq = eq `on` ed25519KeyHashToBytes

instance Ord Ed25519KeyHash where
  compare = compare `on` ed25519KeyHashToBytes

instance Show Ed25519KeyHash where
  show edkh = "(Ed25519KeyHash " <> rawBytesToHex (ed25519KeyHashToBytes edkh)
    <> ")"

instance ToData Ed25519KeyHash where
  toData = toData <<< unwrap <<< ed25519KeyHashToBytes

instance FromData Ed25519KeyHash where
  fromData (Bytes kh) = ed25519KeyHashFromBytes kh
  fromData _ = Nothing

instance ToMetadata Ed25519KeyHash where
  toMetadata = toMetadata <<< ed25519KeyHashToBytes

instance FromMetadata Ed25519KeyHash where
  fromMetadata (Metadata.Bytes kh) = ed25519KeyHashFromBytes kh
  fromMetadata _ = Nothing

-- This is needed for `ApplyArgs`.
instance DecodeAeson Ed25519KeyHash where
  -- ed25519KeyHashFromBech32 goes from Bech32String directly although this
  -- feels unsafe.
  decodeAeson x = caseAesonString
    ( Left $ TypeMismatch $ "Expected Plutus BuiltinByteString but got " <> show
        x
    )
    ( note (TypeMismatch "Invalid Ed25519KeyHash") <<< ed25519KeyHashFromBytes
        <=< note (TypeMismatch "Invalid ByteArray") <<< hexToByteArray
    )
    x

instance EncodeAeson Ed25519KeyHash where
  encodeAeson = encodeAeson <<< rawBytesToHex <<< ed25519KeyHashToBytes

instance Arbitrary Ed25519KeyHash where
  arbitrary =
    unsafePartial fromJust <<< ed25519KeyHashFromBytes <<<
      byteArrayFromIntArrayUnsafe <$> vectorOf 28 (chooseInt 0 255)

-- | Convert ed25519KeyHash to Bech32 representation with given prefix.
-- | Will crash if prefix is invalid (length, mixed-case, etc)
-- | More on prefixes: https://cips.cardano.org/cips/cip5
ed25519KeyHashToBech32Unsafe ∷ String → Ed25519KeyHash → Bech32String
ed25519KeyHashToBech32Unsafe = hashToBech32Unsafe

ed25519KeyHashToBytes :: Ed25519KeyHash -> RawBytes
ed25519KeyHashToBytes = wrap <<< hashToBytes

scriptHashToBech32Unsafe ∷ String → ScriptHash → Bech32String
scriptHashToBech32Unsafe = hashToBech32Unsafe

ed25519KeyHashFromBytes :: ByteArray -> Maybe Ed25519KeyHash
ed25519KeyHashFromBytes = hashFromBytes "Ed25519KeyHash" maybeFfiHelper

ed25519KeyHashFromBech32 :: Bech32String -> Maybe Ed25519KeyHash
ed25519KeyHashFromBech32 = _ed25519KeyHashFromBech32Impl maybeFfiHelper

-- | Convert ed25519KeyHash to Bech32 representation with given prefix.
-- | Will return Nothing if prefix is invalid (length, mixed-case, etc)
-- | More on prefixes: https://cips.cardano.org/cips/cip5
ed25519KeyHashToBech32 :: String -> Ed25519KeyHash -> Maybe Bech32String
ed25519KeyHashToBech32 = _ed25519KeyHashToBech32Impl maybeFfiHelper

-- | blake2b-224 hash digests of serialized monetary scripts
foreign import data ScriptHash :: Type

instance Eq ScriptHash where
  eq = eq `on` scriptHashToBytes

instance Ord ScriptHash where
  compare = compare `on` scriptHashToBytes

instance Show ScriptHash where
  show edkh = "(ScriptHash " <> rawBytesToHex (scriptHashToBytes edkh) <> ")"

instance ToData ScriptHash where
  toData = toData <<< unwrap <<< scriptHashToBytes

instance FromData ScriptHash where
  fromData (Bytes bytes) = scriptHashFromBytes bytes
  fromData _ = Nothing

instance ToMetadata ScriptHash where
  toMetadata = toMetadata <<< scriptHashToBytes

instance FromMetadata ScriptHash where
  fromMetadata (Metadata.Bytes bytes) = scriptHashFromBytes bytes
  fromMetadata _ = Nothing

-- Corresponds to Plutus' `Plutus.V1.Ledger.Api.Script` Aeson instances
instance DecodeAeson ScriptHash where
  decodeAeson = do
    maybe (Left $ TypeMismatch "Expected hex-encoded script hash") Right <<<
      caseAesonString Nothing (Just <=< scriptHashFromBytes <=< hexToByteArray)

instance EncodeAeson ScriptHash where
  encodeAeson sh = encodeAeson $ scriptHashToBytes sh

_ed25519KeyHashToBech32Impl
  ∷ MaybeFfiHelper → String → Ed25519KeyHash → Maybe Bech32String
_ed25519KeyHashToBech32Impl = hashToBech32Impl

scriptHashToBytes :: ScriptHash -> RawBytes
scriptHashToBytes = wrap <<< hashToBytes

_scriptHashToBech32Impl
  ∷ MaybeFfiHelper → String → ScriptHash → Maybe Bech32String
_scriptHashToBech32Impl = hashToBech32Impl

-- | Decodes a script hash from its CBOR bytes encoding
-- | NOTE. It does _not_ compute hash of given bytes.
scriptHashFromBytes :: ByteArray -> Maybe ScriptHash
scriptHashFromBytes = hashFromBytes "ScriptHash" maybeFfiHelper

-- | Decodes a script hash from its Bech32 representation
scriptHashFromBech32 :: Bech32String -> Maybe ScriptHash
scriptHashFromBech32 = _scriptHashFromBech32Impl maybeFfiHelper

-- | Convert scriptHash to Bech32 representation with given prefix.
-- | Will return `Nothing` if prefix is invalid (length, mixed-case, etc)
-- | More on prefixes: https://cips.cardano.org/cips/cip5
scriptHashToBech32 :: String -> ScriptHash -> Maybe Bech32String
scriptHashToBech32 = _scriptHashToBech32Impl maybeFfiHelper

foreign import data VRFKeyHash :: Type

instance Show VRFKeyHash where
  show = hashToBytes >>> byteArrayToHex

instance Eq VRFKeyHash where
  eq = eq `on` show

instance EncodeAeson VRFKeyHash where
  encodeAeson = hashToBytes >>> byteArrayToHex >>> encodeAeson
