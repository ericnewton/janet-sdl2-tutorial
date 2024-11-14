# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/01/01.html
# -*- mode: janet-mode -*-

(use ./sdl)

(defn main [&]
  # Initialize SDL. SDL_Init will return -1 if it fails.
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
	(do
	  (print (string "Error initializing SDL: " (SDL_GetError)))
	  (pause)
	  (os/exit 1)))

  # Create our window
  (def window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 1280 720 SDL_WINDOW_SHOWN))

  # Make sure creating the window succeeded
  (if (not window)
    (do
      (print "Error creating window: " (SDL_GetError))
      (pause)
      # End the program
      (os/exit 1)))

  # Get the surface from the window
  (def winSurface (SDL_GetWindowSurface window))

  # Make sure getting the surface succeeded
  (if (not winSurface)
    (do
      (print "Error getting surface: " (SDL_GetError))
      (pause)
      # End the program
      (os/exit 1)))

  # decode the winSurface pointer into a structure we can examine
  (def surface-struct (buffer-to-struct winSurface SDL_Surface))

  # Fill the window with a white rectangle
  (SDL_FillRect winSurface nil (SDL_MapRGB (surface-struct :format) 255 255 255))

  # Update the window display
  (SDL_UpdateWindowSurface window)

  # Wait
  (pause)

  # Destroy the window. This will also destroy the surface
  (SDL_DestroyWindow window)

  # Quit SDL
  (SDL_Quit)
	
  # End the program
  (os/exit))

