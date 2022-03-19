module FromData
  ( class FromData
  , fromData
  ) where

import Prelude

import Data.Array as Array
import Data.BigInt (BigInt)
import Data.List (List)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(Nothing, Just))
import Data.Ratio (Ratio, reduce)
import Data.Traversable (for, traverse)
import Data.Tuple (Tuple(Tuple))
import Data.Tuple.Nested (type (/\), (/\))
import Prim.TypeError (class Fail, Text)
import Data.Unfoldable (class Unfoldable)
import Types.ByteArray (ByteArray)
import Types.PlutusData (PlutusData(Bytes, Constr, List, Map, Integer))

class FromData (a :: Type) where
  fromData :: PlutusData -> Maybe a

instance FromData Unit where
  fromData (Constr n [])
    | n == zero = Just unit
  fromData _ = Nothing

instance FromData Boolean where
  fromData (Constr n [])
    | n == zero = Just false
    | n == one = Just true
  fromData _ = Nothing

instance Fail (Text "Int is not supported, use BigInt instead") => FromData Int where
  fromData _ = Nothing

instance FromData BigInt where
  fromData (Integer n) = Just n
  fromData _ = Nothing

instance FromData a => FromData (Array a) where
  fromData = fromDataUnfoldable

instance FromData a => FromData (List a) where
  fromData = fromDataUnfoldable

instance (FromData a, FromData b) => FromData (a /\ b) where
  fromData (Constr n [ a, b ])
    | n == zero = Tuple <$> fromData a <*> fromData b
  fromData _ = Nothing

instance (FromData k, Ord k, FromData v) => FromData (Map k v) where
  fromData (Map mp) = do
    Map.fromFoldable <$> for (Map.toUnfoldable mp :: Array _) \(k /\ v) ->
      Tuple <$> fromData k <*> fromData v
  fromData _ = Nothing

instance FromData ByteArray where
  fromData (Bytes res) = Just res
  fromData _ = Nothing

instance (Ord a, EuclideanRing a, FromData a) => FromData (Ratio a) where
  fromData (List [ a, b ]) = reduce <$> fromData a <*> fromData b
  fromData _ = Nothing

instance FromData PlutusData where
  fromData = Just

fromDataUnfoldable :: forall (a :: Type) (t :: Type -> Type). Unfoldable t => FromData a => PlutusData -> Maybe (t a)
fromDataUnfoldable (List entries) = Array.toUnfoldable <$> traverse fromData entries
fromDataUnfoldable _ = Nothing
