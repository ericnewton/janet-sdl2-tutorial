# -*- mode: janet-mode -*-

(ffi/context "/opt/homebrew/lib/libSDL2.dylib")

# selected function signatures
(ffi/defbind SDL_ConvertSurface :ptr [src :ptr  fmt :ptr flags :uint32])
(ffi/defbind SDL_CreateRenderer :ptr [window :ptr index :int flags :uint32])
(ffi/defbind SDL_CreateTextureFromSurface :ptr [renderer :ptr surface :ptr])
(ffi/defbind SDL_CreateWindow :ptr [title :string x :int y :int w :int h :int flags :uint32])
(ffi/defbind SDL_Delay :void [ms :uint32])
(ffi/defbind SDL_DestroyRenderer :void [renderer :ptr])
(ffi/defbind SDL_DestroyTexture :void [texture :ptr])
(ffi/defbind SDL_DestroyWindow :void [window :ptr])
(ffi/defbind SDL_FillRect :ptr [dst :ptr rect :ptr color :uint32])
(ffi/defbind SDL_FreeSurface :void [surface :ptr])
(ffi/defbind SDL_GetError :string [])
(ffi/defbind SDL_GetKeyboardState :ptr [numkeys :ptr])
(ffi/defbind SDL_GetTicks :uint32 [])
(ffi/defbind SDL_GetPerformanceCounter :uint64 [])
(ffi/defbind SDL_GetWindowSurface :ptr [window :ptr])
(ffi/defbind SDL_Init :int [flags :uint32])
(ffi/defbind SDL_LoadBMP_RW :ptr [src :ptr freesrc :int])
(ffi/defbind SDL_MapRGB :uint32 [format :ptr r :uint8 g :uint8 b :uint8])
(ffi/defbind SDL_PollEvent :int [event :ptr])
(ffi/defbind SDL_Quit :void [])
(ffi/defbind SDL_RWFromFile :ptr [path :string mode :string])
(ffi/defbind SDL_RenderClear :int [renderer :ptr])
(ffi/defbind SDL_RenderCopy :int [renderer :ptr texture :ptr srcrect :ptr dstrect :ptr])
(ffi/defbind SDL_RenderCopyEx :int [renderer :ptr texture :ptr srctrect :ptr dstrect :ptr angle :double center :ptr flip :int])
(ffi/defbind SDL_RenderDrawLine :int [renderer :ptr x1 :int y1 :int x2 :int y2 :int])
(ffi/defbind SDL_RenderDrawPoint :int [renderer :ptr x :int y :int])
(ffi/defbind SDL_RenderDrawRect :int [renderer :ptr rect :ptr])
(ffi/defbind SDL_RenderFillRect :int [renderer :ptr rect :ptr])
(ffi/defbind SDL_RenderPresent :int [renderer :ptr])
(ffi/defbind SDL_SetMainReady :void [])
(ffi/defbind SDL_SetRenderDrawColor :int [renderer :ptr r :uint8 g :uint8 b :uint8 a :uint8])
(ffi/defbind SDL_SetTextureColorMod :int [texture :ptr r :uint g :uint b :uint])
(ffi/defbind SDL_StartTextInput :void [])
(ffi/defbind SDL_StopTextInput :void [])
(ffi/defbind SDL_UpdateWindowSurface :int [window :ptr])
(ffi/defbind SDL_UpperBlitScaled :int [src :ptr srcrect :ptr dst :ptr dstrect :ptr])
(ffi/defbind SDL_UpperBlit :int [src :ptr srcrect :ptr dst :ptr dstrect :ptr])

# There are C macros for these
(def SDL_BlitScaled SDL_UpperBlitScaled)
(def SDL_BlitSurface SDL_UpperBlit)
(defn SDL_LoadBMP [path]
  (SDL_LoadBMP_RW (SDL_RWFromFile path "rb") 1))

# Arguments of alternating pairs of type and name keys (eg. [:uint32
# :timestamp] and return a struct with the names and types under
# separate keys. Order is preserved. Note that the initial list is not
# nested. For example, [:int32 :a :int8 b] -> {:names [:a :b] :types
# [:int32 :int8]}
(defn named-types [& pairs]
  (let [types @[]
        names @[]]
    (each i (range 0 (length pairs) 2)
      (do
        (array/push types (get pairs i))
        (array/push names (get pairs (+ i 1)))))
    {:names (tuple ;names) :types (tuple ;types)}))

# The SDL_Event type is a C union of many types, with the first two
# elements of each component in common. The ffi interface doesn't have
# the notion of a union, but we can re-interpret the same hunk of
# memory to have different layouts, which is what a union does.

# Hoist the common values into a value we can re-use in type of
# SDL_Event structure:
(def- common [:uint32 :type
              :uint32 :timestamp      # milliseconds
             ])

# For completeness, this is what the common part looks like as the
# named-types struct:
(def SDL_CommonEvent (named-types ;common))

# Define a few more that we'll use. Notice we're splicing the common
# bit into the start of each definition.
(def SDL_DisplayEvent
  (named-types
   ;common
   :uint32 :display    # The associated display index
     :uint8 :event     # ::SDL_DisplayEventID 
     :uint8 :padding1
     :uint8 :padding2
     :uint8 :padding3
     :int32 :data1     # event dependent data
     ))
(def SDL_WindowEvent
  (named-types
   ;common
   :uint32 :windowID   # The associated window 
     :uint8  :event    # ::SDL_WindowEventID
     :uint8  :padding1
     :uint8  :padding2
     :uint8  :padding3
     :int32  :data1    # event dependent data
     :int32  :data2    # event dependent data
     ))
(def SDL_MouseMotionEvent
  (named-types
   ;common
   :uint32 :windowID   # The window with mouse focus, if any
     :uint32 :which    # The mouse instance id, or SDL_TOUCH_MOUSEID
     :uint32 :state    # The current button state 
     :int32  :x        # X coordinate, relative to window
     :int32  :y        # Y coordinate, relative to window
     :int32  :xrel     # The relative motion in the X direction
     :int32  :yrel     # The relative motion in the Y direction
     ))
(def SDL_MouseButtonEvent
  (named-types
   ;common
   :uint32 :windowID  # The window with mouse focus, if any
     :uint32 :which   # The mouse instance id, or SDL_TOUCH_MOUSEID
     :uint8  :button  # The mouse button index
     :uint8  :state   # ::SDL_PRESSED or ::SDL_RELEASED
     :uint8  :clicks  # 1 for single-click, 2 for double-click, etc.
     :uint8  :padding1
     :int32  :x       # X coordinate, relative to window
     :int32  :y       # Y coordinate, relative to window
     ))
(def SDL_TEXTINPUTEVENT_TEXT_SIZE 32)
(def SDL_TextInputEvent
  (named-types
   ;common
   :uint32 :windowID   # The window with keyboard focus, if any
   @[:char SDL_TEXTINPUTEVENT_TEXT_SIZE] :text # The input text
   ))

# A sub-structure defined for SDL_KeyboardEvent
(def SDL_Keysym
  [
   #SDL_Scancode (an enum) 
   :int :scancode      # SDL physical key code
   #SDL_Keycode  (an enum
   :int :sym           # SDL virtual key code
   :uint16 :mod        # current key modifiers
   :uint32 :unused
  ])
(def SDL_KeyboardEvent
  (named-types
   ;common
   :uint32 :windowID # The window with keyboard focus, if any
     :uint8 :state # ::SDL_PRESSED or ::SDL_RELEASED
     :uint8 :repeat # Non-zero if this is a key repeat
     :uint8 :padding2
     :uint8 :padding3
     # SDL_Keysym keysym... just splice in the members: there are no
     # name conflicts and the ffi/struct system doesn't support nested
     # structs
     ;SDL_Keysym
))


(def- rect [:int :x
     :int :y
     :int :w
     :int :h])

(def SDL_Rect
  (named-types ;rect))

(def SDL_Surface
  (named-types
    :uint32 :flags              # Read-only
    :ptr :format                # Read-only
    :int :w
    :int :h                     # Read-only
    :int :pitch                 # Read-only
    :ptr :pixels                # Read-write

    # Application data associated with the surface
    :ptr :userdata              # Read-write

    # information needed for surfaces requiring locks
    :int :locked                 # Read-only

    # list of BlitMap that hold a reference to this surface
    :ptr :list_blitmap          # Private

    # clipping information
    # SDL_Rect clip_rect       # Read-only
    ;rect

    # info for fast blit mapping to other surfaces
    :ptr :map                   # Private

    # Reference count -- used when freeing surface
    :int :refcount              # Read-mostly
    ))

(def SDL_Color
  (named-types
    :uint8 :r
    :uint8 :g
    :uint8 :b
    :uint8 :a))

# Given a buffer of bytes and a set of names and types (see
# named-types) decode the buffer into a structure with named values.
(defn buffer-to-struct [buffer named-types]
  (let [names (named-types :names)
        types (named-types :types)
        values (ffi/read (ffi/struct ;types) buffer)]
    (struct ;(interleave names values))))

# reverse of the buffer-to-struct
(defn struct-to-buffer [data named-types]
  (let [names (named-types :names)
        types (named-types :types)
        values (map (fn [name] (get data name nil)) names)]
    (ffi/write types values)))

(def SDL_INIT_TIMER          0x00000001)
(def SDL_INIT_AUDIO          0x00000010)
(def SDL_INIT_VIDEO          0x00000020)  # SDL_INIT_VIDEO implies SDL_INIT_EVENTS
(def SDL_INIT_JOYSTICK       0x00000200)  # SDL_INIT_JOYSTICK implies SDL_INIT_EVENTS
(def SDL_INIT_HAPTIC         0x00001000)
(def SDL_INIT_GAMECONTROLLER 0x00002000)  # SDL_INIT_GAMECONTROLLER implies SDL_INIT_JOYSTICK
(def SDL_INIT_EVENTS         0x00004000)
(def SDL_INIT_SENSOR         0x00008000)
(def SDL_INIT_NOPARACHUTE    0x00100000)  # compatibility; this flag is ignored.
(def SDL_INIT_EVERYTHING (bor SDL_INIT_TIMER SDL_INIT_AUDIO SDL_INIT_VIDEO
                              SDL_INIT_EVENTS SDL_INIT_JOYSTICK SDL_INIT_HAPTIC
                              SDL_INIT_GAMECONTROLLER SDL_INIT_SENSOR)
            )

(def SDL_INIT_VIDEO 0x00000020)

(def SDL_WINDOW_SHOWN 0x00000004)
(def SDL_WINDOWPOS_UNDEFINED 0x1FFF0000)

# event types
(def SDL_QUIT 0x100)
(def SDL_DISPLAYEVENT 0x150) # Display state change 
(def SDL_WINDOWEVENT  0x200) # Window state change
(def SDL_KEYDOWN      0x300) # Key pressed
(def SDL_KEYUP        (inc SDL_KEYDOWN)) # Key released
(def SDL_TEXTEDITING  (inc SDL_KEYUP))  # Keyboard text editing (composition)
(def SDL_TEXTINPUT    (inc SDL_TEXTEDITING)) # Keyboard text input
(def SDL_AUDIODEVICEADDED 0x1100)

# Mouse events
(def SDL_MOUSEMOTION  0x400)  # Mouse moved
(def SDL_MOUSEBUTTONDOWN (inc SDL_MOUSEMOTION)) # Mouse button pressed
(def SDL_MOUSEBUTTONUP (inc SDL_MOUSEBUTTONDOWN)) # Mouse button pressed
(def event-type-names
  {
     SDL_QUIT :quit
     SDL_DISPLAYEVENT :display
     SDL_WINDOWEVENT :window
     SDL_MOUSEMOTION :mousemotion
     SDL_MOUSEBUTTONDOWN :mousebuttondown
     SDL_KEYUP :keyup
     SDL_KEYDOWN :keydown
     SDL_TEXTEDITING :textediting
     SDL_TEXTINPUT  :textinput
     SDL_AUDIODEVICEADDED :audiodeviceadded
  })

(def SDL_RELEASED 0)
(def SDL_PRESSED 1)

# scancodes
(def SDL_SCANCODE_0 39)
(def SDL_SCANCODE_1 30)
(def SDL_SCANCODE_2 31)
(def SDL_SCANCODE_3 32)
(def SDL_SCANCODE_4 33)
(def SDL_SCANCODE_5 34)
(def SDL_SCANCODE_6 35)
(def SDL_SCANCODE_7 36)
(def SDL_SCANCODE_8 37)
(def SDL_SCANCODE_9 38)
(def SDL_SCANCODE_A 4)
(def SDL_SCANCODE_AC_BACK 270)
(def SDL_SCANCODE_AC_BOOKMARKS 274)
(def SDL_SCANCODE_AC_FORWARD 271)
(def SDL_SCANCODE_AC_HOME 269)
(def SDL_SCANCODE_AC_REFRESH 273)
(def SDL_SCANCODE_AC_SEARCH 268)
(def SDL_SCANCODE_AC_STOP 272)
(def SDL_SCANCODE_AGAIN 121)
(def SDL_SCANCODE_ALTERASE 153)
(def SDL_SCANCODE_APOSTROPHE 52)
(def SDL_SCANCODE_APP1 283)
(def SDL_SCANCODE_APP2 284)
(def SDL_SCANCODE_APPLICATION 101)
(def SDL_SCANCODE_AUDIOFASTFORWARD 286)
(def SDL_SCANCODE_AUDIOMUTE 262)
(def SDL_SCANCODE_AUDIONEXT 258)
(def SDL_SCANCODE_AUDIOPLAY 261)
(def SDL_SCANCODE_AUDIOPREV 259)
(def SDL_SCANCODE_AUDIOREWIND 285)
(def SDL_SCANCODE_AUDIOSTOP 260)
(def SDL_SCANCODE_B 5)
(def SDL_SCANCODE_BACKSLASH 49)
(def SDL_SCANCODE_BACKSPACE 42)
(def SDL_SCANCODE_BRIGHTNESSDOWN 275)
(def SDL_SCANCODE_BRIGHTNESSUP 276)
(def SDL_SCANCODE_C 6)
(def SDL_SCANCODE_CALCULATOR 266)
(def SDL_SCANCODE_CALL 289)
(def SDL_SCANCODE_CANCEL 155)
(def SDL_SCANCODE_CAPSLOCK 57)
(def SDL_SCANCODE_CLEAR 156)
(def SDL_SCANCODE_CLEARAGAIN 162)
(def SDL_SCANCODE_COMMA 54)
(def SDL_SCANCODE_COMPUTER 267)
(def SDL_SCANCODE_COPY 124)
(def SDL_SCANCODE_CRSEL 163)
(def SDL_SCANCODE_CURRENCYSUBUNIT 181)
(def SDL_SCANCODE_CURRENCYUNIT 180)
(def SDL_SCANCODE_CUT 123)
(def SDL_SCANCODE_D 7)
(def SDL_SCANCODE_DECIMALSEPARATOR 179)
(def SDL_SCANCODE_DELETE 76)
(def SDL_SCANCODE_DISPLAYSWITCH 277)
(def SDL_SCANCODE_DOWN 81)
(def SDL_SCANCODE_E 8)
(def SDL_SCANCODE_EJECT 281)
(def SDL_SCANCODE_END 77)
(def SDL_SCANCODE_ENDCALL 290)
(def SDL_SCANCODE_EQUALS 46)
(def SDL_SCANCODE_ESCAPE 41)
(def SDL_SCANCODE_EXECUTE 116)
(def SDL_SCANCODE_EXSEL 164)
(def SDL_SCANCODE_F 9)
(def SDL_SCANCODE_F1 58)
(def SDL_SCANCODE_F10 67)
(def SDL_SCANCODE_F11 68)
(def SDL_SCANCODE_F12 69)
(def SDL_SCANCODE_F13 104)
(def SDL_SCANCODE_F14 105)
(def SDL_SCANCODE_F15 106)
(def SDL_SCANCODE_F16 107)
(def SDL_SCANCODE_F17 108)
(def SDL_SCANCODE_F18 109)
(def SDL_SCANCODE_F19 110)
(def SDL_SCANCODE_F2 59)
(def SDL_SCANCODE_F20 111)
(def SDL_SCANCODE_F21 112)
(def SDL_SCANCODE_F22 113)
(def SDL_SCANCODE_F23 114)
(def SDL_SCANCODE_F24 115)
(def SDL_SCANCODE_F3 60)
(def SDL_SCANCODE_F4 61)
(def SDL_SCANCODE_F5 62)
(def SDL_SCANCODE_F6 63)
(def SDL_SCANCODE_F7 64)
(def SDL_SCANCODE_F8 65)
(def SDL_SCANCODE_F9 66)
(def SDL_SCANCODE_FIND 126)
(def SDL_SCANCODE_G 10)
(def SDL_SCANCODE_GRAVE 53)
(def SDL_SCANCODE_H 11)
(def SDL_SCANCODE_HELP 117)
(def SDL_SCANCODE_HOME 74)
(def SDL_SCANCODE_I 12)
(def SDL_SCANCODE_INSERT 73)
(def SDL_SCANCODE_INTERNATIONAL1 135)
(def SDL_SCANCODE_INTERNATIONAL2 136)
(def SDL_SCANCODE_INTERNATIONAL3 137)
(def SDL_SCANCODE_INTERNATIONAL4 138)
(def SDL_SCANCODE_INTERNATIONAL5 139)
(def SDL_SCANCODE_INTERNATIONAL6 140)
(def SDL_SCANCODE_INTERNATIONAL7 141)
(def SDL_SCANCODE_INTERNATIONAL8 142)
(def SDL_SCANCODE_INTERNATIONAL9 143)
(def SDL_SCANCODE_J 13)
(def SDL_SCANCODE_K 14)
(def SDL_SCANCODE_KBDILLUMDOWN 279)
(def SDL_SCANCODE_KBDILLUMTOGGLE 278)
(def SDL_SCANCODE_KBDILLUMUP 280)
(def SDL_SCANCODE_KP_0 98)
(def SDL_SCANCODE_KP_00 176)
(def SDL_SCANCODE_KP_000 177)
(def SDL_SCANCODE_KP_1 89)
(def SDL_SCANCODE_KP_2 90)
(def SDL_SCANCODE_KP_3 91)
(def SDL_SCANCODE_KP_4 92)
(def SDL_SCANCODE_KP_5 93)
(def SDL_SCANCODE_KP_6 94)
(def SDL_SCANCODE_KP_7 95)
(def SDL_SCANCODE_KP_8 96)
(def SDL_SCANCODE_KP_9 97)
(def SDL_SCANCODE_KP_A 188)
(def SDL_SCANCODE_KP_AMPERSAND 199)
(def SDL_SCANCODE_KP_AT 206)
(def SDL_SCANCODE_KP_B 189)
(def SDL_SCANCODE_KP_BACKSPACE 187)
(def SDL_SCANCODE_KP_BINARY 218)
(def SDL_SCANCODE_KP_C 190)
(def SDL_SCANCODE_KP_CLEAR 216)
(def SDL_SCANCODE_KP_CLEARENTRY 217)
(def SDL_SCANCODE_KP_COLON 203)
(def SDL_SCANCODE_KP_COMMA 133)
(def SDL_SCANCODE_KP_D 191)
(def SDL_SCANCODE_KP_DBLAMPERSAND 200)
(def SDL_SCANCODE_KP_DBLVERTICALBAR 202)
(def SDL_SCANCODE_KP_DECIMAL 220)
(def SDL_SCANCODE_KP_DIVIDE 84)
(def SDL_SCANCODE_KP_E 192)
(def SDL_SCANCODE_KP_ENTER 88)
(def SDL_SCANCODE_KP_EQUALS 103)
(def SDL_SCANCODE_KP_EQUALSAS400 134)
(def SDL_SCANCODE_KP_EXCLAM 207)
(def SDL_SCANCODE_KP_F 193)
(def SDL_SCANCODE_KP_GREATER 198)
(def SDL_SCANCODE_KP_HASH 204)
(def SDL_SCANCODE_KP_HEXADECIMAL 221)
(def SDL_SCANCODE_KP_LEFTBRACE 184)
(def SDL_SCANCODE_KP_LEFTPAREN 182)
(def SDL_SCANCODE_KP_LESS 197)
(def SDL_SCANCODE_KP_MEMADD 211)
(def SDL_SCANCODE_KP_MEMCLEAR 210)
(def SDL_SCANCODE_KP_MEMDIVIDE 214)
(def SDL_SCANCODE_KP_MEMMULTIPLY 213)
(def SDL_SCANCODE_KP_MEMRECALL 209)
(def SDL_SCANCODE_KP_MEMSTORE 208)
(def SDL_SCANCODE_KP_MEMSUBTRACT 212)
(def SDL_SCANCODE_KP_MINUS 86)
(def SDL_SCANCODE_KP_MULTIPLY 85)
(def SDL_SCANCODE_KP_OCTAL 219)
(def SDL_SCANCODE_KP_PERCENT 196)
(def SDL_SCANCODE_KP_PERIOD 99)
(def SDL_SCANCODE_KP_PLUS 87)
(def SDL_SCANCODE_KP_PLUSMINUS 215)
(def SDL_SCANCODE_KP_POWER 195)
(def SDL_SCANCODE_KP_RIGHTBRACE 185)
(def SDL_SCANCODE_KP_RIGHTPAREN 183)
(def SDL_SCANCODE_KP_SPACE 205)
(def SDL_SCANCODE_KP_TAB 186)
(def SDL_SCANCODE_KP_VERTICALBAR 201)
(def SDL_SCANCODE_KP_XOR 194)
(def SDL_SCANCODE_L 15)
(def SDL_SCANCODE_LALT 226)
(def SDL_SCANCODE_LANG1 144)
(def SDL_SCANCODE_LANG2 145)
(def SDL_SCANCODE_LANG3 146)
(def SDL_SCANCODE_LANG4 147)
(def SDL_SCANCODE_LANG5 148)
(def SDL_SCANCODE_LANG6 149)
(def SDL_SCANCODE_LANG7 150)
(def SDL_SCANCODE_LANG8 151)
(def SDL_SCANCODE_LANG9 152)
(def SDL_SCANCODE_LCTRL 224)
(def SDL_SCANCODE_LEFT 80)
(def SDL_SCANCODE_LEFTBRACKET 47)
(def SDL_SCANCODE_LGUI 227)
(def SDL_SCANCODE_LSHIFT 225)
(def SDL_SCANCODE_M 16)
(def SDL_SCANCODE_MAIL 265)
(def SDL_SCANCODE_MEDIASELECT 263)
(def SDL_SCANCODE_MENU 118)
(def SDL_SCANCODE_MINUS 45)
(def SDL_SCANCODE_MODE 257)
(def SDL_SCANCODE_MUTE 127)
(def SDL_SCANCODE_N 17)
(def SDL_SCANCODE_NONUSBACKSLASH 100)
(def SDL_SCANCODE_NONUSHASH 50)
(def SDL_SCANCODE_NUMLOCKCLEAR 83)
(def SDL_SCANCODE_O 18)
(def SDL_SCANCODE_OPER 161)
(def SDL_SCANCODE_OUT 160)
(def SDL_SCANCODE_P 19)
(def SDL_SCANCODE_PAGEDOWN 78)
(def SDL_SCANCODE_PAGEUP 75)
(def SDL_SCANCODE_PASTE 125)
(def SDL_SCANCODE_PAUSE 72)
(def SDL_SCANCODE_PERIOD 55)
(def SDL_SCANCODE_POWER 102)
(def SDL_SCANCODE_PRINTSCREEN 70)
(def SDL_SCANCODE_PRIOR 157)
(def SDL_SCANCODE_Q 20)
(def SDL_SCANCODE_R 21)
(def SDL_SCANCODE_RALT 230)
(def SDL_SCANCODE_RCTRL 228)
(def SDL_SCANCODE_RETURN 40)
(def SDL_SCANCODE_RETURN2 158)
(def SDL_SCANCODE_RGUI 231)
(def SDL_SCANCODE_RIGHT 79)
(def SDL_SCANCODE_RIGHTBRACKET 48)
(def SDL_SCANCODE_RSHIFT 229)
(def SDL_SCANCODE_S 22)
(def SDL_SCANCODE_SCROLLLOCK 71)
(def SDL_SCANCODE_SELECT 119)
(def SDL_SCANCODE_SEMICOLON 51)
(def SDL_SCANCODE_SEPARATOR 159)
(def SDL_SCANCODE_SLASH 56)
(def SDL_SCANCODE_SLEEP 282)
(def SDL_SCANCODE_SOFTLEFT 287)
(def SDL_SCANCODE_SOFTRIGHT 288)
(def SDL_SCANCODE_SPACE 44)
(def SDL_SCANCODE_STOP 120)
(def SDL_SCANCODE_SYSREQ 154)
(def SDL_SCANCODE_T 23)
(def SDL_SCANCODE_TAB 43)
(def SDL_SCANCODE_THOUSANDSSEPARATOR 178)
(def SDL_SCANCODE_U 24)
(def SDL_SCANCODE_UNDO 122)
(def SDL_SCANCODE_UNKNOWN 0)
(def SDL_SCANCODE_UP 82)
(def SDL_SCANCODE_V 25)
(def SDL_SCANCODE_VOLUMEDOWN 129)
(def SDL_SCANCODE_VOLUMEUP 128)
(def SDL_SCANCODE_W 26)
(def SDL_SCANCODE_WWW 264)
(def SDL_SCANCODE_X 27)
(def SDL_SCANCODE_Y 28)
(def SDL_SCANCODE_Z 29)
(def SDL_NUM_SCANCODES 512)

# keycodes
(def SDLK_SPACE (get " " 0))
(def SDLK_ESCAPE (get "\e" 0))
(def SDLK_BACKSPACE (get "\b" 0))


# SDL_RendererFlip enum
(def SDL_FLIP_NONE 0x00000000)       # Do not flip
(def SDL_FLIP_HORIZONTAL 0x00000001) # flip horizontally
(def SDL_FLIP_VERTICAL 0x00000002)   # flip vertically


# render flags

(def SDL_RENDERER_ACCELERATED 0x00000002)

(def SDL_BLENDMODE_ADD 0x00000002)

(def SDL_EventSize 64)
(defn make-sdl-event []
  (put @"" SDL_EventSize 0))

# read events until a QUIT event occurs
(defn pause []
  (prompt :exit
    (def event-buffer (make-sdl-event))
    (forever
     (while (not= 0 (SDL_PollEvent event-buffer))
       (let [event (buffer-to-struct event-buffer SDL_CommonEvent)
             type (event :type)]
         (if (= type SDL_QUIT)
           (return :exit))))
     # sleep instead of busy wait
     (SDL_Delay 10))))

(defn sdl-pressed-keys []
 []
 (def keys (ffi/read @[:uint8 SDL_NUM_SCANCODES] (SDL_GetKeyboardState nil)))
 (def result @{})
 (each key [range SDL_NUM_SCANCODES]
   (if (= SDL_PRESSED (get keys key))
     (put result key true))))
 
(defn int-array-to-string [arr]
  (get (string/split "\0" (string/from-bytes ;arr)) 0))
     
