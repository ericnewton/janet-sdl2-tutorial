# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/07/07.html
# -*- mode: janet-mode -*-

(use ./sdl)
(use ./sdl-image)
(use ./sdl-ttf)

# Pointers to our window, renderer, texture, and font
(var window nil)
(var renderer nil)
(var texture nil)
(var text nil)
(var font nil)
(var input @"")

(defn _loop []

  (def e (make-sdl-event))

  # Clear the window to white
  (SDL_SetRenderDrawColor renderer 255 255 255 255)
  (SDL_RenderClear renderer)

  (prompt :exit
     # Event _loop
     (while  (not= 0 (SDL_PollEvent e))
       (def type ((buffer-to-struct e SDL_CommonEvent) :type))
       (case type
	 SDL_QUIT (return :exit false)
	 SDL_TEXTINPUT
	 (let [e-text (buffer-to-struct e SDL_TextInputEvent)
	       text (int-array-to-string (e-text :text))]
	   (buffer/push input text))
	 SDL_KEYDOWN
	 (let [e-key (buffer-to-struct e SDL_KeyboardEvent)]
	   (if (= (e-key :sym) SDLK_BACKSPACE)
	     (buffer/popn input 1))))

       # Render texture
       (SDL_RenderCopy renderer texture nil nil)

       (def foreground [0 0 0 0])

       (if (> (length input) 0)
	 (let [text-surf-buffer (TTF_RenderText_Solid font (string input) foreground)
	       text_surf (buffer-to-struct text-surf-buffer SDL_Surface)
	       text (SDL_CreateTextureFromSurface renderer text-surf-buffer)
	       dest (struct-to-buffer
		     {:x (math/round (- 320 (/ (text_surf :w) 2)))
		      :y 240
		      :w (text_surf :w)
		      :h (text_surf :h)}
		     SDL_Rect)]
	   (SDL_RenderCopy renderer text nil dest)
	   (SDL_DestroyTexture text)
	   (SDL_FreeSurface text-surf-buffer)))

	# Update window
       (SDL_RenderPresent renderer))
     true))

(defn init []
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (error (string "Error initializing SDL: " (SDL_GetError))))

    # Initialize SDL_image with PNG loading subsystem
  (if (< (IMG_Init IMG_INIT_PNG) 0)
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

  # Load bitmap into surface
  (def buffer (IMG_Load "data/07/test.png"))
  (if (nil? buffer)
    (error (string "Error loading image 07/test.png: " (IMG_GetError))))

  (set texture (SDL_CreateTextureFromSurface renderer buffer))
  (SDL_FreeSurface buffer)
  (if (nil? texture) 
    (error (string "Error creating texture: " (SDL_GetError))))

  # Load font
  (set font (TTF_OpenFont "data/07/font.ttf" 72))
  (if (nil? font)
    (error (string "Error loading font: " (TTF_GetError))))

  # Start sending SDL_TextInput events
  (SDL_StartTextInput)
  true)

(defn kill []
  (SDL_StopTextInput)
  (TTF_CloseFont font)
  (SDL_DestroyTexture texture)

  (SDL_DestroyRenderer renderer)
  (SDL_DestroyWindow window)

  (TTF_Quit)
  (IMG_Quit)
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
