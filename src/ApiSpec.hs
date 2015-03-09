-- | Defines an api spec (to be built after the static checking of the AST) and helped methods over
-- it.
module ApiSpec where

import qualified Data.Map as M

-- | Identifier of an enum, struct, field...
type Id = String

-- | The route of a resource.
type Route = String

-- | An enum value.
type EnumValue = String

-- | An enum is a list of values.
type EnumInfo = [EnumValue]

-- | A field modifier.
data Modifier =
    Hidden
  | Immutable
  | Required
  | PrimaryKey deriving Eq

-- | A field has a type, an identifier and a list of modifiers.
type FieldInfo = (Id, Type, [Modifier])

-- | A struct is a list of fields.
type StructInfo = [FieldInfo]

-- | A type can be a primitive one (int, long, double, bool...), an enum, a struct, or a list of
-- another type.
data Type = TInt
          | TLong
          | TFloat
          | TDouble
          | TBool
          | TString
          | TEnum Id
          | TStruct Id
          | TList Type deriving (Eq, Show)


type Enums = M.Map Id EnumInfo

type Structs = M.Map Id StructInfo

type Resources = M.Map Route Id

-- | The spec of an api is a set of enums and structs, along with the resources.
data ApiSpec = AS { enums     :: Enums
                  , structs   :: Structs
                  , resources :: Resources }

-- | Gets the primary key of a struct.
getPrimaryKey :: StructInfo -> Id
getPrimaryKey structInfo =
  case filter hasPkModifier structInfo of
    [(x, _, _)] -> x
    _ -> error "A struct should only have one primary key."
  where
    hasPkModifier (_, _, modifiers) = PrimaryKey `elem` modifiers

-- | Search for the Immutable modifier in the given field.
isImmutable :: FieldInfo -> Bool
isImmutable (_, _, modifiers) = Immutable `elem` modifiers
