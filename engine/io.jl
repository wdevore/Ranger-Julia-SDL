using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer



function handle_events!(event::Array{UInt8}, ev_type)
    if (ev_type == SDL2.KEYDOWN)# || ev_type == SDL2.KEYUP)
        # struct KeyboardEvent <: AbstractEvent
        #     _type::Uint32       1   4
        #     timestamp::Uint32   5   4 
        #     windowID::Uint32    9   4
        #     state::UInt8 13     13  1
        #     repeat::UInt8 14    14  1
        #     padding2::UInt8 15  15  1
        #     padding3::UInt8 16  16  1
        #     keysym::Keysym      17 
        # end
        # struct Keysym
        #     scancode::Scancode Sint32 17  4
        #     sym::Keycode Sint32       21  4
        #     mod::Uint16               25  2
        #     unused::Uint32            27
        # end
        print_event(event) 
        # handle_key_press(event)
        false
    elseif (ev_type == SDL2.QUIT) 
        println("Quit detected")
        true
    end
end
