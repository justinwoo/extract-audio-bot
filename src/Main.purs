module Main where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, makeAff, throwError)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (error)
import Effect.Uncurried as EU
import Foreign (Foreign)
import Node.Encoding (Encoding(..))
import Node.FS.Aff as FS
import TelegramBot (Bot, Promise)
import TelegramBot as TB
import Tortellini (parsellIni)
import YTDL as YTDL

newtype ChatId = ChatId Int

type FileOptions =
  { file_id :: String
  , file_name :: String
  }

sendDocumentFromBuffer :: Bot -> ChatId -> Foreign -> FileOptions -> Effect (Effect (Promise Unit))
sendDocumentFromBuffer = EU.runEffectFn4 _sendDocumentFromBuffer

foreign import _sendDocumentFromBuffer :: EU.EffectFn4 Bot ChatId Foreign FileOptions (Effect (Promise Unit))

type Config =
  { bot ::
      { token :: String
      , master :: Int
      }
  }

parsellIni' :: String -> Aff Config
parsellIni' s =
  case parsellIni s of
    Right (config :: Config) -> pure config
    Left e -> throwError $ error $ "Invalid config error: " <> show e

main :: Effect Unit
main = launchAff_ do
  config <- parsellIni' =<< FS.readTextFile UTF8 "./config.ini"
  bot <- liftEffect $ TB.connect (config.bot.token)
  liftEffect $ TB.sendMessage bot config.bot.master "Downloading..."
  _ <- makeAff \cb -> do
    YTDL.downloadAudio "https://youtu.be/cGsu8SbQJcQ" \r -> do
      TB.sendMessage bot config.bot.master "Uploading..."
      promise <- sendDocumentFromBuffer
        bot
        (ChatId config.bot.master)
        r.buffer
        { file_id: r.title
        , file_name: r.title
        }
      TB.runPromise
        (EU.mkEffectFn1 $ cb <<< Left)
        (EU.mkEffectFn1 $ cb <<< Right)
        =<< promise
      pure unit
    mempty
  pure unit
