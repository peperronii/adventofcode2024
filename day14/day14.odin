package day14

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import "core:time"
import str "core:strings"

ROBOT_COUNT :: 500
ROW_SIZE :: 103
COL_SIZE :: 101

Robot :: struct {
	c_col : int,
	c_row : int,
	v_col : int,
	v_row : int
}

render :: proc(robots : []Robot) {
	canvas : [ROW_SIZE][COL_SIZE]bool
	for r in robots do canvas[r.c_row][r.c_col] = true
	for row in canvas {
		for col in row {
			if col do fmt.print('|')
			else do fmt.print('-')
		}
		fmt.print('\n')
	}
	fmt.print('\n')
	fmt.print('\n')
}

render_and_calculate :: proc(robots : []Robot) -> (safety_factor : int) {
	q1 , q2 , q3 , q4 : int
	for r in robots {
		switch r.c_row {
			case 0..<ROW_SIZE/2 : {
				switch r.c_col {
					case 0..<COL_SIZE/2 : q1 += 1
					case (COL_SIZE/2 + 1) ..< COL_SIZE : q2 += 1 
				}
			}
			case (ROW_SIZE/2 + 1) ..< ROW_SIZE : {
				switch r.c_col {
					case 0..<COL_SIZE/2 : q3 += 1
					case (COL_SIZE/2 + 1) ..< COL_SIZE : q4 += 1 
				}
			}
		}
	}
	safety_factor = q1 * q2 * q3 * q4
	return
}


get_ints :: proc( s : string )  -> (i,j,k,l : int) {
	start, count, phase : int
	in_num : bool

	for r in s {
		switch r {
			case '0'..='9','-' :
				if !in_num {
					phase += 1
					in_num = true
					start = count
				}
			case : if in_num {
				in_num = false
				buf, _ := strconv.parse_int(s[start: count])
				switch phase {
					case 1 : i = buf
					case 2 : j = buf
					case 3 : k = buf
					case 4 : l = buf
				}
			}
		}
		count += 1
	}
	return
}

load :: proc() -> (input : [ROBOT_COUNT]Robot) {
	st := #load(`input.txt`, string)
	buf := str.split_lines_after(st)
	for i : int ; i < 500 ; i += 1 {
		r := &input[i]
		r.c_col, r.c_row, r.v_col, r.v_row = get_ints(buf[i])
	}
	return
}


solve :: proc() -> (safety_factor : int) {
	
	robots := load()
	for seconds in 1..=200000 {
		rowbuf : [103]int
		colbuf : [101]int
		for &r in robots {
			r.c_col += r.v_col
			r.c_col = (COL_SIZE + r.c_col) % COL_SIZE
			colbuf[r.c_col] += 1
			r.c_row += r.v_row
			r.c_row = (ROW_SIZE + r.c_row) % ROW_SIZE
			rowbuf[r.c_row] += 1
		}
		loop : for num in rowbuf {
			if num >= 30 {
				for num2 in colbuf {
					if num2 >= 20 {
						render(robots[:])
						break loop
					}
				}
			}
		}
		fmt.printfln("Seconds : %v", seconds)
		
	}

	// safety_factor = render_and_calculate(robots[:])
	return 
}

main :: proc() {
	//set tracking allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	defer {
		for _, value in tracking_allocator.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
		}
		for b in tracking_allocator.bad_free_array {
			fmt.printf("Bad Free : %v", b)
		}
	}
	t := new(time.Stopwatch)
	defer free(t)
	time.stopwatch_start(t)
	fmt.printfln("The answer is: %v ", solve())
	time.stopwatch_stop(t)
	fmt.println(time.stopwatch_duration(t^))
}