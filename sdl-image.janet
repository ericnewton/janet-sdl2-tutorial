# -*- mode: janet-mode -*-

(import ./sdl)

(ffi/context "/opt/homebrew/lib/libSDL2_image.dylib")

(ffi/defbind IMG_Init :int [flags :int])
(ffi/defbind IMG_Load :ptr [path :string])
(ffi/defbind IMG_Quit :void [])

(def IMG_GetError sdl/SDL_GetError)
(def IMG_INIT_JPG 0x00000001)
(def IMG_INIT_PNG 0x00000002)
