# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/02/02.html
# -*- mode: janet-mode -*-

(use ./sdl)

(varfn load [])
(varfn init [])
(varfn kill [])


# Pointers to our window and surfaces
(var window nil)
(var winSurface nil)
(var image1 nil)
(var image2 nil)

(defn main [&] 
  (if (not (init))
    (error "initialization failed"))

  (if (not (load))
    (error "load failed"))

  # Blit image to entire window
  (SDL_BlitSurface image1 nil winSurface nil)

  # Blit image to scaled portion of window
  (def dest (struct-to-buffer {:x 160 :y 120 :w 320 :h 240} SDL_Rect))
  
  (SDL_BlitScaled image2 nil winSurface dest)

  # Update window
  (SDL_UpdateWindowSurface window)
  (pause)

  (kill)
  (os/exit 0))

(varfn load []
  # Load images
  # Temporary surfaces to load images into
  # This should use only 1 temp surface, but for conciseness we use two
  (def temp1 (SDL_LoadBMP "data/02/test1.bmp"))
  (def temp2 (SDL_LoadBMP "data/02/test2.bmp"))
  (defer (map SDL_FreeSurface [temp1 temp2])
    # Make sure loads succeeded
    (if (not (and temp1 temp2) )
      (let [msg (string "Error loading image: " (SDL_GetError))]
	(pause)
	(error msg)))

    # Extract format from the surface
    (def format ((buffer-to-struct winSurface SDL_Surface) :format))

    # Format surfaces
    (set image1 (SDL_ConvertSurface temp1 format 0))
    (set image2 (SDL_ConvertSurface temp2 format 0))

    # Make sure format succeeded
    (if (not (and image1 image2))
      (let [msg (string "Error converting surface: " (SDL_GetError))]
	(pause)
	(error msg))))
  true)

(varfn init
  [] 
  # See last example for comments
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (let [msg (string "Error initializing SDL: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  (set window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 640 480 SDL_WINDOW_SHOWN))
  (if (not window)
    (let [msg (string "Error creating window: " (SDL_GetError))]
      (pause)
      (error msg)))

  (set winSurface (SDL_GetWindowSurface window))
  (if (not winSurface)
    (let [msg (string "Error getting surface: " (SDL_GetError))]
      (pause)
      (error msg)))
  true)

(varfn kill []
  # Free images
  (SDL_FreeSurface image1)
  (SDL_FreeSurface image2)

  # Quit
  (SDL_DestroyWindow window)
  (SDL_Quit))
