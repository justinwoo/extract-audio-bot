module YTDL where

import Prelude

import Effect (Effect)
import Effect.Uncurried as EU
import Foreign (Foreign)

type Callback =
  { title :: String, buffer :: Foreign } -> Effect Unit

downloadAudio :: String -> Callback -> Effect Unit
downloadAudio = EU.runEffectFn2 _downloadAudio

foreign import _downloadAudio :: EU.EffectFn2 String Callback Unit
