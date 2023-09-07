module Ctl.Internal.Types.PubKeyHash
  ( PaymentPubKeyHash(PaymentPubKeyHash)
  , PubKeyHash(PubKeyHash)
  , StakePubKeyHash(StakePubKeyHash)
  , payPubKeyHashBaseAddress
  , payPubKeyHashEnterpriseAddress
  , payPubKeyHashRewardAddress
  , pubKeyHashBaseAddress
  , pubKeyHashEnterpriseAddress
  , pubKeyHashRewardAddress
  , stakePubKeyHashRewardAddress
  , ed25519RewardAddress
  ) where

import Prelude

import Aeson
  ( class DecodeAeson
  , class EncodeAeson
  , decodeAeson
  , encodeAeson
  , (.:)
  )
import Ctl.Internal.FromData (class FromData)
import Ctl.Internal.Metadata.FromMetadata (class FromMetadata)
import Ctl.Internal.Metadata.ToMetadata (class ToMetadata)
import Ctl.Internal.Serialization.Address
  ( Address
  , EnterpriseAddress
  , NetworkId
  , RewardAddress
  , baseAddressToAddress
  , enterpriseAddress
  , enterpriseAddressToAddress
  , keyHashCredential
  , paymentKeyHashStakeKeyHashAddress
  , rewardAddress
  , rewardAddressToAddress
  )
import Ctl.Internal.Serialization.Hash (Ed25519KeyHash)
import Ctl.Internal.ToData (class ToData)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Show.Generic (genericShow)

newtype PubKeyHash = PubKeyHash Ed25519KeyHash

derive instance Generic PubKeyHash _
derive instance Newtype PubKeyHash _
derive newtype instance Eq PubKeyHash
derive newtype instance FromData PubKeyHash
derive newtype instance FromMetadata PubKeyHash
derive newtype instance Ord PubKeyHash
derive newtype instance ToData PubKeyHash
derive newtype instance ToMetadata PubKeyHash

instance Show PubKeyHash where
  show = genericShow

instance EncodeAeson PubKeyHash where
  encodeAeson x = encodeAeson { getPubKeyHash: unwrap x }

instance DecodeAeson PubKeyHash where
  decodeAeson a = do
    obj <- decodeAeson a
    wrap <$> obj .: "getPubKeyHash"

ed25519EnterpriseAddress
  :: forall (n :: Type)
   . Newtype n Ed25519KeyHash
  => NetworkId
  -> n
  -> EnterpriseAddress
ed25519EnterpriseAddress network pkh =
  enterpriseAddress
    { network
    , paymentCred: keyHashCredential (unwrap pkh)
    }

ed25519RewardAddress
  :: forall (n :: Type)
   . Newtype n Ed25519KeyHash
  => NetworkId
  -> n
  -> RewardAddress
ed25519RewardAddress network skh =
  rewardAddress
    { network
    , paymentCred: keyHashCredential (unwrap skh)
    }

pubKeyHashBaseAddress :: NetworkId -> PubKeyHash -> StakePubKeyHash -> Address
pubKeyHashBaseAddress networkId pkh skh =
  baseAddressToAddress $ paymentKeyHashStakeKeyHashAddress networkId
    (unwrap pkh)
    (unwrap $ unwrap skh)

pubKeyHashRewardAddress :: NetworkId -> PubKeyHash -> Address
pubKeyHashRewardAddress networkId =
  rewardAddressToAddress <<< ed25519RewardAddress networkId

pubKeyHashEnterpriseAddress :: NetworkId -> PubKeyHash -> Address
pubKeyHashEnterpriseAddress networkId =
  enterpriseAddressToAddress <<< ed25519EnterpriseAddress networkId

newtype PaymentPubKeyHash = PaymentPubKeyHash PubKeyHash

derive instance Generic PaymentPubKeyHash _
derive instance Newtype PaymentPubKeyHash _
derive newtype instance Eq PaymentPubKeyHash
derive newtype instance FromData PaymentPubKeyHash
derive newtype instance Ord PaymentPubKeyHash
derive newtype instance ToData PaymentPubKeyHash

instance EncodeAeson PaymentPubKeyHash where
  encodeAeson (PaymentPubKeyHash pkh) = encodeAeson
    { "unPaymentPubKeyHash": pkh }

instance DecodeAeson PaymentPubKeyHash where
  decodeAeson json = do
    obj <- decodeAeson json
    wrap <$> obj .: "unPaymentPubKeyHash"

instance Show PaymentPubKeyHash where
  show = genericShow

newtype StakePubKeyHash = StakePubKeyHash PubKeyHash

derive instance Generic StakePubKeyHash _
derive instance Newtype StakePubKeyHash _
derive newtype instance Eq StakePubKeyHash
derive newtype instance FromData StakePubKeyHash
derive newtype instance Ord StakePubKeyHash
derive newtype instance ToData StakePubKeyHash

instance Show StakePubKeyHash where
  show = genericShow

payPubKeyHashRewardAddress :: NetworkId -> PaymentPubKeyHash -> Address
payPubKeyHashRewardAddress networkId (PaymentPubKeyHash pkh) =
  pubKeyHashRewardAddress networkId pkh

payPubKeyHashBaseAddress
  :: NetworkId -> PaymentPubKeyHash -> StakePubKeyHash -> Address
payPubKeyHashBaseAddress networkId (PaymentPubKeyHash pkh) skh =
  pubKeyHashBaseAddress networkId pkh skh

payPubKeyHashEnterpriseAddress :: NetworkId -> PaymentPubKeyHash -> Address
payPubKeyHashEnterpriseAddress networkId (PaymentPubKeyHash pkh) =
  pubKeyHashEnterpriseAddress networkId pkh

stakePubKeyHashRewardAddress :: NetworkId -> StakePubKeyHash -> Address
stakePubKeyHashRewardAddress networkId =
  rewardAddressToAddress <<< ed25519RewardAddress networkId <<< unwrap
