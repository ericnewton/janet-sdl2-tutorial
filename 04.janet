# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/04/04.html
# -*- mode: janet-mode -*-

(use ./sdl)

(varfn init [])
(varfn kill [])
(varfn _loop [])		# loop is a built-in macro name

# Pointers to our window and renderer
(var window nil)
(var renderer nil)

(defn main [&]
  (if (not (init))
    (error "could not initialize!"))

  (while (_loop)
    (SDL_Delay 10))

  (kill)
  (os/exit 0))


# For mouse rectangle (static to presist between function calls)
(var- mx0 -1)
(var- my0 -1)
(var- mx1 -1)
(var- my1 -1)

(varfn _loop []
  (prompt :exit
     (def event-buffer (make-sdl-event))
     # Clear the window to white
     (SDL_SetRenderDrawColor renderer 255 255 255 255)
     (SDL_RenderClear renderer)

     # Event loop
     (while (not= 0 (SDL_PollEvent event-buffer))
       (def e (buffer-to-struct event-buffer SDL_CommonEvent))
       (def type (e :type))
       (case type
	 SDL_QUIT (return :exit false)
	 SDL_MOUSEBUTTONDOWN
	 (let [e-mousebutton (buffer-to-struct event-buffer SDL_MouseButtonEvent)]
	   (set mx0 (get e-mousebutton :x))
	   (set my0 (get e-mousebutton :y)))
	 SDL_MOUSEMOTION
	 (let [e-mousemotion (buffer-to-struct event-buffer SDL_MouseMotionEvent)]
	   (set mx1 (get e-mousemotion :x))
	   (set my1 (get e-mousemotion :y)))
	 SDL_MOUSEBUTTONUP
	 (do
	   (set mx0 -1)
	   (set my0 -1)
	   (set mx1 -1)
	   (set my1 -1))))

     # Set drawing color to black
     (SDL_SetRenderDrawColor renderer 0 0 0 255)
     
     # Test key states - this could also be done with events
     # translate the keyboard state into a tuple of values
     (def keys (ffi/read @[:uint8 SDL_NUM_SCANCODES] (SDL_GetKeyboardState nil)))
     
     (if (= SDL_PRESSED (get keys SDL_SCANCODE_1))
	 (SDL_RenderDrawPoint renderer 10 10))

     (if (= SDL_PRESSED (get keys SDL_SCANCODE_2))
       (SDL_RenderDrawLine renderer 10 20 10 100))

     (if (= SDL_PRESSED (get keys SDL_SCANCODE_3))
       (do
	 (def r (struct-to-buffer {:x 20 :y 20 :w 100 :h 100} SDL_Rect))
	 (SDL_RenderFillRect renderer r)))

     # Render mouse rectangle
     (if (not= mx0 -1)
       (do
	 (def r (struct-to-buffer {:x mx0 :y my0 :w (- mx1 mx0) :h (- my1 my0)} SDL_Rect))
	 (SDL_RenderDrawRect renderer r)))

     # Update window
     (SDL_RenderPresent renderer)
     true))

(varfn init []
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (let [msg (string "Error initializing SDL: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  (set window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 150 150 SDL_WINDOW_SHOWN))
  (if (nil? window)
    (let [msg (string "Error creating window: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  (set renderer (SDL_CreateRenderer window -1 SDL_RENDERER_ACCELERATED))
  (if (nil? renderer)
    (let [msg (string "Error creating renderer: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  (SDL_SetRenderDrawColor renderer 255 255 255 255)
  (SDL_RenderClear renderer)
  true)

(varfn kill[]
  # Quit
  (SDL_DestroyRenderer renderer)
  (SDL_DestroyWindow window)
  (SDL_Quit))
