if &cp || exists('g:scroll_loaded')
  finish
endif

let g:scrollbar_loaded = 1

function! ScrollBar(...)
    let top_line = line("w0")
    let bottom_line = line("w$")
    let current_line = line('.')
    let lines_count = line('$')

    if a:0 == 6 && type(a:4) == 3 && type(a:5) == 3
                \ && len(a:4) == len(a:5) 
        let gripper_left_symbols = a:4
        let gripper_right_symbols = a:5
        let scaling = len(gripper_left_symbols)
        let part = a:6
    else
        let part = 'a'
        let scaling = 1
    endif

    " Compute gripper position and size as if we have scaling times a:1
    " characters available and shrink everything back just before returning 
    let scrollbar_length = str2nr(a:1) * scaling

    " Gripper positions are 0 based (0..scrollbar_length-1)
    let gripper_position = float2nr((top_line - 1.0) / lines_count 
\       * scrollbar_length)
    let gripper_length = float2nr(ceil((bottom_line - top_line + 1.0)  
\       / lines_count * scrollbar_length)) 

    " Users expect to see the scrollbar in the leftmost position only if we
    " are at the very top of the buffer
    if (top_line > 1) && (gripper_position == 0)
        " Since the top line is not visible shift the gripper by one position
        let gripper_position = 1
        if (gripper_position + gripper_length > scrollbar_length)
            " Shrink the gripper if we end up after the end of the scrollbar 
            let gripper_length = gripper_length - 1
        endif
    endif

    if (bottom_line < lines_count) 
\       && (gripper_position + gripper_length == scrollbar_length)
        " As before, if the last line is not on the screen but the scrollbar
        " seems to indicate so then either move the scrollbar position leftwise
        " by one position or decrease its length
        if gripper_position > 0
            let gripper_position = gripper_position - 1
        else
            let gripper_length = gripper_length - 1
        endif
    endif

    " Shrink everything back to the range [0, a:1)
    let gripper_position = 1.0 * gripper_position / scaling
    let gripper_length = 1.0 * gripper_length / scaling
    let scrollbar_length = 1.0 * scrollbar_length / scaling

    " The left of the gripper is broken in 3 parts.  The left and right are
    " fractionals in the range [0, len(a:4)). 
    let gripper_length_left = ceil(gripper_position) - gripper_position
    " Hackish rounding errors workaround. If `gripper_length
    " - gripper_lenght_left` is 0.9999.. we force it to 1 before rounding it
    let gripper_length_middle = floor(round((gripper_length 
                \ - gripper_length_left)*100.0)/100.0)
    let gripper_length_right = gripper_length - gripper_length_left 
                \ - gripper_length_middle

    " Time to build the actual scrollbar
    let scrollbar = ''
    if part != 'm' && part != 'r'
        let scrollbar .= repeat(a:2, float2nr(floor(gripper_position)))

        let gripper_symbol_index = float2nr(round(gripper_length_left * scaling))
        if gripper_symbol_index != 0
            let scrollbar .= gripper_left_symbols[gripper_symbol_index]
        endif
    endif
    
    if part != 'l' && part != 'r'
        let scrollbar .= repeat(a:3, float2nr(gripper_length_middle)) 
    endif

    if part != 'l' && part != 'm'
        let gripper_symbol_index = float2nr(round(gripper_length_right * scaling))
        if gripper_symbol_index != 0
            let scrollbar .= gripper_right_symbols[gripper_symbol_index]
        endif
        let scrollbar .= repeat(a:2, float2nr(scrollbar_length 
                    \ - ceil(gripper_position + gripper_length)))
    endif


    return scrollbar
endfunction
