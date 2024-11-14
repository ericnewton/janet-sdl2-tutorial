# -*- mode: janet-mode -*-

(import ./sdl)

(ffi/context "/opt/homebrew/lib/libSDL2_mixer.dylib")

(ffi/defbind Mix_FreeChunk :void [chunk :ptr])
(ffi/defbind Mix_FreeMusic :void [music :ptr])
(ffi/defbind Mix_HaltMusic :int [])
(ffi/defbind Mix_LoadMUS :ptr [path :string])
(ffi/defbind Mix_LoadWAV :ptr [path :string])
(ffi/defbind Mix_OpenAudio :ptr [frequency :int format :uint16 channels :int chunksize :int])
(ffi/defbind Mix_PauseMusic :void [])
(ffi/defbind Mix_PausedMusic :int [])
(ffi/defbind Mix_PlayChannel :int [channel :int chunk :ptr loops :int])
(ffi/defbind Mix_PlayMusic :int [music :ptr loops :int])
(ffi/defbind Mix_Quit :void [])
(ffi/defbind Mix_ResumeMusic :int [])
  
(def Mix_GetError sdl/SDL_GetError)

(def AUDIO_S16LSB 0x8010)
(def AUDIO_S16MSB 0x9010)
(def- is-little-endian? (= 1 (get (int/to-bytes (int/u64 0x1)) 0)))
(def AUDIO_S16SYS (if is-little-endian? AUDIO_S16LSB AUDIO_S16MSB))
  
(def MIX_DEFAULT_FORMAT AUDIO_S16SYS)
