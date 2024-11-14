(use ./sdl)
(use ./sdl-image)
(use ./sdl-ttf)

# Gravity in pixels per second squared
(def GRAVITY 750.0)

(var window nil)
(var renderer nil)
(var box nil)
(var font nil)

(def- round math/round)

(defn renderText [text dest]
  (def fg [0 0 0 0])
  (def surf-ptr (TTF_RenderText_Solid font text fg))
  (def surf (buffer-to-struct surf-ptr SDL_Surface))

  (put dest :w (surf :w))
  (put dest :h (surf :h))

  (def tex (SDL_CreateTextureFromSurface renderer surf-ptr))

  (SDL_RenderCopy renderer tex nil (struct-to-buffer dest SDL_Rect))
  (SDL_DestroyTexture tex)
  (SDL_FreeSurface surf-ptr))

(defn- randint [x] (round (* (math/random) x)))

(defn _loop []
  (math/seedrandom (os/time))

  # Physics squares
  (def squares @[])

  (var running true)
  
  (var totalFrameTicks 0)
  (var totalFrames 0)
  (while running
    # Start frame timing
    (++ totalFrames)
    (def startTicks (SDL_GetTicks))
    (def startPerf (SDL_GetPerformanceCounter))

    (def e (make-sdl-event))

    (SDL_SetRenderDrawColor renderer 255 255 255 255)
    (SDL_RenderClear renderer)

    # Event loop
    (while (not= 0 (SDL_PollEvent e))
      (def e-common (buffer-to-struct e SDL_CommonEvent))
      (def type (e-common :type))
      (case type
	  SDL_QUIT (set running false)
	  SDL_MOUSEBUTTONDOWN
	  (let [e-button (buffer-to-struct e SDL_MouseButtonEvent)
		s @{:x (e-button :x)
		    :y (e-button :y)
		    :w (+ (randint 50) 25)
		    :h (+ (randint 50) 25)
		    :yvelocity -500
		    :xvelocity (- (randint 500) 250)
		    :lastUpdate (SDL_GetTicks)
		    :born (SDL_GetTicks)}]
	    (array/push squares s))))

    # Physics loop
    (var index 0)
    (while (< index (length squares))
      (def s (get squares index))
      (def time (SDL_GetTicks))
      (def dT (/ (- time (s :lastUpdate)) 1000))

      (put s :yvelocity (+ (s :yvelocity) (* dT GRAVITY)))
      (put s :y (+ (s :y) (* (get s :yvelocity) dT)))
      (put s :x (+ (s :x) (* (get s :xvelocity) dT)))

      (if (> (s :y) (- 480 (s :h)))
	(do
	  (put s :y (- 480 (s :h)))
	  (put s :xvelocity 0)
	  (put s :yvelocity 0)))
      
      (put s :lastUpdate time)
      (if (> (s :lastUpdate) (+ (get s :born) 5000))
	(array/remove squares index)
	(++ index)))

    # Render loop
    (each s squares
      (def dest {:x (round (s :x)) :y (round (s :y)) :w (round (s :w)) :h (round (s :h))})
      (SDL_RenderCopy renderer box nil (struct-to-buffer dest SDL_Rect)))

    # Delay for a random number of ticks - this makes the frame rate variable,
    # demonstrating that the physics is independent of the frame rate.
    (SDL_Delay (randint 25))

    # End frame timing
    (def endTicks (SDL_GetTicks))
    (def endPerf (SDL_GetPerformanceCounter))
    (def framePerf (- endPerf startPerf))
    (def frameTime (/ (- endTicks startTicks) 1000.0))
    (+= totalFrameTicks (- endTicks startTicks))

    # Strings to display
    (def fps (string/format "Current FPS: %.1f" (/ 1.0 frameTime)))
    (def avg (string/format "Average FPS: %.1f" (/ 1000.0 (/ totalFrameTicks totalFrames))))
    (def perf (string/format "Current Perf: %d" framePerf))

    # Display strings
    (def dest @{:x 10 :y 10 :h 0 :w 0 })
    (renderText fps dest)
    (put dest :y (+ (dest :y) 24))
    (renderText avg dest)
    (put dest :y (+ (dest :y) 24))
    (renderText perf dest)
    
    # Display window
    (SDL_RenderPresent renderer)))

(defn init []
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (error (string "Error initializing SDL: " (SDL_GetError))))

    # Initialize SDL_image with PNG loading subsystem
  (if (< (IMG_Init IMG_INIT_JPG) 0)
    (error (string "Error initializing IMG: " (IMG_GetError))))

  # Initialize SDL_ttf
  (if (< (TTF_Init) 0)
    (error (string "Error initializing SDL_ttf: " (IMG_GetError))))
  
  (set window (SDL_CreateWindow "Example" SDL_WINDOWPOS_UNDEFINED SDL_WINDOWPOS_UNDEFINED 640 480 SDL_WINDOW_SHOWN))
  (if (nil? window)
    (error (string "Error creating window: " (SDL_GetError))))

  (set renderer (SDL_CreateRenderer window -1 SDL_RENDERER_ACCELERATED))
  (if (nil? renderer)
    (error (string "Error creating renderer: " (SDL_GetError))))

  (def buffer (IMG_Load "data/08/box.jpg"))
  (if (nil? buffer)
    (error (string "Error loading image 08/box.jpg: " (IMG_GetError))))

  (set box (SDL_CreateTextureFromSurface renderer buffer))
  (SDL_FreeSurface buffer)
  (if (nil? box) 
    (error (string "Error creating texture: " (SDL_GetError))))

  (set font (TTF_OpenFont "data/08/font.ttf" 24))
  (if (nil? font)
    (error (string "Error loading font: " (TTF_GetError))))

  true)

(defn kill []
  (TTF_CloseFont font)
  (SDL_DestroyTexture box)

  (SDL_DestroyRenderer renderer)
  (SDL_DestroyWindow window)

  (TTF_Quit)
  (IMG_Quit)
  (SDL_Quit))

(defn main [&]
  (if (not (init))
    (os/exit 1))

  (_loop)

  (kill)
  (os/exit))


