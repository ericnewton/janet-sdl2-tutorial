# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/03/03.html
# -*- mode: janet-mode -*-

(use ./sdl)

(varfn init [])
(varfn kill [])
(varfn load [])
(varfn _loop [])		# loop is a built-in macro name

# Pointers to our window and surfaces
(var window nil)
(var winSurface nil)
(var image1 nil)
(var image2 nil)

(defn main [&]
  (if (not (init))
    (error "could not initialize!"))

  (if (not (load))
    (error "could not load"))
    
  (while (_loop)
    (SDL_Delay 10))

  (kill)
  (os/exit 0))

(var- renderImage2 nil)

(varfn _loop []
  (def e-buffer (make-sdl-event))
  (var result true)

  # Blit image to entire window
  (SDL_BlitSurface image1 nil winSurface nil)

  (while (not= 0 (SDL_PollEvent e-buffer))
    (def e (buffer-to-struct e-buffer SDL_CommonEvent))
    (case (e :type)
      SDL_QUIT (set result false)
      SDL_KEYDOWN (set renderImage2 true)
      SDL_KEYUP (set renderImage2 false)
      # can also test individual keys, modifier flags, etc, etc.
      SDL_MOUSEMOTION nil # etc.
      ))

  (if renderImage2
    (let [dest (struct-to-buffer {:x 160 :y 120 :w 320 :h 240} SDL_Rect)]
      (SDL_BlitScaled image2 nil winSurface dest)))

  # Update window
  (SDL_UpdateWindowSurface window)
  
  result)

(varfn load []
  # Load images
  # Temporary surfaces to load images into
  # This should use only 1 temp surface, but for conciseness we use two
  (def temp1 (SDL_LoadBMP "data/02/test1.bmp"))
  (def temp2 (SDL_LoadBMP "data/02/test2.bmp"))
  (defer (map SDL_FreeSurface [temp1 temp2])
    # Make sure loads succeeded
    (if (or (nil? temp1) (nil? temp2)))
      (let [msg (string "Error loading image: " (SDL_GetError))]
	(pause)
	(error msg)))

    # Extract format from the surface
    (def s (buffer-to-struct winSurface SDL_Surface))
    (def format (s :format))

    # Format surfaces
    (set image1 (SDL_ConvertSurface temp1 format 0))
    (set image2 (SDL_ConvertSurface temp2 format 0))

    # Make sure format succeeded
    (if (or (nil? image1) (nil? image2))
      (let [msg (string "Error converting surface: " (SDL_GetError))]
	(pause)
	(error msg))))
  true)


(varfn init []
  # See last example for comments
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (let [msg (string "Error initializing SDL: " (SDL_GetError))]
      (pause)
      (error msg)))

  (set window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 640 480 SDL_WINDOW_SHOWN))
  (if (nil? window )
    (let [msg (string "Error creating window: " (SDL_GetError))]
      (pause)
      (error msg)))

  (set winSurface (SDL_GetWindowSurface window))
  (if (nil? winSurface)
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

(main)
