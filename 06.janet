# Converted from C/C++ here:
# https://thenumb.at/cpp-course/sdl2/06/06.html
# -*- mode: janet-mode -*-

(use ./sdl)
(use ./sdl-image)
(use ./sdl-mixer)

# Pointers to our window, renderer, texture, music, and sound
(var window nil)
(var renderer nil)
(var texture nil)
(var music nil)
(var sound nil)

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
	 SDL_QUIT  (return :exit false)
	 SDL_KEYDOWN
	 (let [e-key (buffer-to-struct e SDL_KeyboardEvent)
	       sym (e-key :sym)]
	   (if (= sym SDLK_SPACE)
	     (if (= 1 (Mix_PausedMusic))
	       (Mix_ResumeMusic)
	       (Mix_PauseMusic))
	     (if (= sym SDLK_ESCAPE)
	       (Mix_HaltMusic))))
	 SDL_MOUSEBUTTONDOWN
	 # Play sound once on the first available channel
	 (Mix_PlayChannel -1 sound 0)))

     # Render texture
     (SDL_RenderCopy renderer texture nil nil)

     # Update window
     (SDL_RenderPresent renderer)
     true))

(defn init
  []
  (if (< (SDL_Init SDL_INIT_EVERYTHING) 0)
    (let [msg (string "Error initializing SDL: " (SDL_GetError))]
      (print msg)
      (pause)
      (error msg)))

  # Initialize SDL_image with PNG loading subsystem
  (if (< (IMG_Init IMG_INIT_PNG) 0)
    (let [msg (string "Error initializing IMG: " (IMG_GetError))]
      (print msg)
      (pause)
      (error msg)))

  # Initialize SDL_mixer with our audio format
  (if (< (Mix_OpenAudio 44100 MIX_DEFAULT_FORMAT 2 1024) 0)
    (let [msg (string "Error initializing SDL_mixer: " (Mix_GetError))]
	  (print msg)
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
  (def buffer (IMG_Load "data/06/test.png"))
  (if (nil? buffer)
    (let [msg (string "Error loading image 06/test.png: " (IMG_GetError))]
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

  # Load music
  (set music (Mix_LoadMUS "06/music.wav"))
  (if (nil? music)
    (let [msg (string "Error loading music: " (Mix_GetError))]
      (print msg)
      (pause)
      (error msg)))

  # Load sound
  (set sound (Mix_LoadWAV "06/scratch.wav"))
  (if (nil? sound)
    (let [msg (string "Error loading sound: " (Mix_GetError))]
      (print msg)
      (pause)
      (error msg)))

  # Play music forever
  (Mix_PlayMusic music -1)
  true)

(defn kill
  []
  (SDL_DestroyTexture texture)
  (Mix_FreeMusic music)
  (Mix_FreeChunk sound)

  (SDL_DestroyRenderer renderer)
  (SDL_DestroyWindow window)

  (IMG_Quit)
  (Mix_Quit)
  (SDL_Quit))


(defn main [&]
  (if (not (init))
    (os/exit 1))

  (while (_loop)
    # wait before processing the next frame
    (SDL_Delay 10))

  (kill)
  (os/exit))

