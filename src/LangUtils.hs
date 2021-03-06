-- | Contains useful methods to work with the defined types (both from the language
-- specification/bnfc and the 'ApiSpec' module).
module LangUtils where

import qualified Data.Set          as S
import           Language.Abs
import qualified TypeCheck.ApiSpec as AS

-- | Extracts the name of the 'Specification' (AST).
specName :: Specification -- ^ Specification returned by the parser
         -> String -- ^ Name of the specification
specName (Spec (Nm (Ident n)) _ _ _ _ _) = n

-- | Extracts the version of the 'Specification' (AST).
specVersion :: Specification -- ^ Specification returned by the parser
            -> String -- ^ Version of the specification
specVersion (Spec _(Ver (VerIdent v)) _ _ _ _) = v

-- | Extracts the name of an enum.
enumName :: EnumType -- ^ Enum information
         -> String -- ^ Name of the enum type
enumName (DefEnum (Ident name) _) = name

-- | Extracts the values of an enum.
enumVals :: EnumType -- ^ Enum information
         -> [EnumVal] -- ^ List of enum values
enumVals (DefEnum _ vals) = vals

enumValName :: EnumVal -- ^ Enum value information
            -> String -- ^ Identifier of the enum value
enumValName (EnVal (Ident name)) = name

-- | Extracts the name of a struct.
strName :: StructType -- ^ The struct info
        -> String -- ^ The name of the struct
strName (DefStr (Ident name) _) = name

-- | Extracts the fields of a struct.
strFields :: StructType -- ^ Struct info
          -> [Field] -- ^ List of fields of the struct
strFields (DefStr _ fields) = fields

-- | Extracts the name of a resource.
resName :: Resource -- ^ Resource information
        -> String -- ^ Name of the resource
resName (Res (Ident name) _ _) = name

-- | Extracts the route of a resource.
resRoute :: Resource -- ^ Resource information
         -> String -- ^ Route of the resource
resRoute (Res _ (RouteIdent route) _) = route

-- | Extracts the write mode of a resource.
resIsWritable :: Resource -- ^ Resource information
              -> Bool -- ^ True if it is writable, False otherwise
resIsWritable (Res _ _ mode) = mode == Write

-- | Extracts the name of a field.
fieldName :: Field -- ^ Field information
          -> String -- ^ Name of the field
fieldName (FDef _ (Ident name) _) = name

-- | Extracts the annotation of a field.
fieldAnnotations :: Field -- ^ Field information
                 -> [Annotation] -- ^ List of annotations
fieldAnnotations (FDef annotations _ _) = annotations

-- | Extracts the type (defined by the language specification/bnfc) of a field.
fieldType :: Field -- ^ Field information
          -> FType -- ^ Type of the field
fieldType (FDef _ _ ft) = ft

-- | Extracts the type (defined in 'ApiSpec') of a field.
fieldSpecType :: (S.Set String, S.Set String) -- ^ (Struct names, Enum names)
              -> FType -- ^ Field type
              -> AS.Type -- ^ 'ApiSpec' field type
fieldSpecType _ FBoolean = AS.TBool
fieldSpecType _ FString = AS.TString
fieldSpecType _ FInt = AS.TInt
fieldSpecType _ FLong = AS.TLong
fieldSpecType _ FDouble = AS.TDouble
fieldSpecType _ FFloat = AS.TFloat
fieldSpecType (strs, enums) (FDefined (Ident n)) | n `S.member` enums = AS.TEnum n
                                                 | n `S.member` strs = AS.TStruct n
                                                 | otherwise = error $ "getType: " ++ n ++ " is not defined."
fieldSpecType as (FList type') = AS.TList $ fieldSpecType as type'

