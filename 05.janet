# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/05/05.html
# -*- mode: janet-mode -*-

(use ./sdl)

# Pointers to our window, renderer, and texture
(var window nil)
(var renderer nil)
(var texture nil)

(var mx -1)
(var my -1)
(var rot 0.)

(defn _loop []
  (def e (make-sdl-event))
  
  # Clear the window to white
  (SDL_SetRenderDrawColor renderer 255 255 255 255)
  (SDL_RenderClear renderer)

  # Event loop
  (prompt :exit
     (while (not= 0 (SDL_PollEvent e))
       (def e-common (buffer-to-struct e SDL_CommonEvent))
       (case (e-common :type)
	 SDL_QUIT (return :exit false)
	 SDL_MOUSEMOTION
	 (let [e-motion (buffer-to-struct e SDL_MouseMotionEvent)]
	   (set mx (e-motion :x))
	   (set my (e-motion :y)))))

     (if (not= mx -1)
       (let [
	     # Distance across window
	     wpercent (/ mx 640.0)
	     hpercent (/ my 480.0)

	     # Color
	     r (math/round (* wpercent 255))
	     g (math/round (* hpercent 255))]

	 # Color mod (b will always be zero)
	 (SDL_SetTextureColorMod texture r g 0)

	 (-= mx 320)
	 (-= my 240)
	 
	 (set rot (* (math/atan (/ my mx)) (/ 180.0 math/pi)))
	 (if (< mx 0)
	   (-= rot 180))
	))
     (set mx -1)
     (set my -1)

     # Render texture
     (def dest (struct-to-buffer {:x 240 :y 180 :w 160 :h 120} SDL_Rect))
     (def keys (ffi/read @[:uint8 SDL_NUM_SCANCODES] (SDL_GetKeyboardState nil)))
     (def f-pressed? (= (get keys SDL_SCANCODE_F) SDL_PRESSED))
     (SDL_RenderCopyEx renderer texture nil dest rot nil (if f-pressed? SDL_FLIP_VERTICAL SDL_FLIP_NONE))

     # Update window
     (SDL_RenderPresent renderer)
     true))

(defn init []
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (let [msg (string "Error initializing SDL: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  (set window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 640 480 SDL_WINDOW_SHOWN))
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

  # Load bitmap into surface
  (def buffer (SDL_LoadBMP "data/05/test.bmp"))
  (if (nil? buffer)
    (let [msg (string "Error loading image test.bmp: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))
  
  # Create texture
  (set texture (SDL_CreateTextureFromSurface renderer buffer))
  
  # Free surface as it's no longer needed
  (SDL_FreeSurface buffer)

  (if (nil? texture)
    (let [msg (string "Error creating texture: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))
  true)

(defn kill []
  (SDL_DestroyTexture texture)
  (SDL_DestroyRenderer renderer)
  (SDL_DestroyWindow window)
  (SDL_Quit)
)


(defn main [&]
  (if (not (init))
    (os/exit 1))

  (while (_loop)
    # wait before processing the next frame
    (SDL_Delay 10))

  (kill)
  (os/exit))
