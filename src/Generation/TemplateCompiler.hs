{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
module Generation.TemplateCompiler where

import           Data.Data
import qualified Data.Text.Lazy        as TL
import           Data.Typeable         ()
import           Paths_Harmony
import           Text.Hastache
import           Text.Hastache.Context

data SchemaVar = SchemaVar { varName    :: String
                           , varType    :: String
                           , isKey      :: Bool
                           , isRequired :: Bool } deriving (Show, Data, Typeable)

data Schema = Schema { schemaName  :: String
                     , schemaRoute :: String
                     , keyField    :: String
                     , schemaVars  :: [SchemaVar] } deriving (Show, Data, Typeable)

data Service = Service { name    :: String
                       , version :: String
                       , schema  :: [Schema] } deriving (Show, Data, Typeable)

-- | Given a template and a service object, it renders the server.
render:: String -> Service -> IO TL.Text
render templateLoc service =
  do
    template <- getDataFileName templateLoc >>= readFile
    let context = mkGenericContext service in
      hastacheStr defaultConfig (encodeStr template) context