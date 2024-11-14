# -*- mode: janet-mode -*-

(import ./sdl)

(ffi/context "/opt/homebrew/lib/libSDL2_ttf.dylib")

(ffi/defbind TTF_Init :int [])
(ffi/defbind TTF_OpenFont :ptr [path :string ptsize :int])
(ffi/defbind TTF_RenderText_Solid :ptr [font :ptr text :string color @[:uchar 4]])
(ffi/defbind TTF_CloseFont :void [font :ptr])
(ffi/defbind TTF_Quit :void [])


(def TTF_GetError sdl/SDL_GetError)
