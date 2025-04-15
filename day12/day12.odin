package day12

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import "core:time"
import str "core:strings"


SIZE :: 140
crd :: struct {
	row : int,
	col : int,
	wall : [dir]bool // N E S W directions
}


unit :: struct {
	row : int,
	col : int,
	facing : dir
}

dir :: enum { N, E, S, W }

rotate_clock_wise :: proc(d : dir) -> (d_: dir) {
	switch d {
		case .N : d_ = .E
		case .E : d_ = .S
		case .S : d_ = .W
		case .W : d_ = .N
	}
	return
}

rotate_anti_clock_wise :: proc(d : dir) -> (d_ :dir) {
	switch d {
		case .N : d_ = .W
		case .E : d_ = .N
		case .S : d_ = .E
		case .W : d_ = .S
	}
	return
}

step_and_check :: proc( row, col : int , d : dir,) -> (row_, col_ : int , ok : bool) {
	drow := 1 if d == .S else -1 if d == .N else 0
	dcol := -1 if d == .W else 1 if d == .E else 0
	row_ = row + drow
	col_ = col + dcol
	if is_inside(row_, col_) do ok = true
	else do ok = false
	return
}

is_inside :: proc(x,y : int) -> bool {
	if x < SIZE && x >= 0 {
		if y < SIZE && y >= 0 do return true
	}

	return false
}

load :: proc() -> (input : [SIZE][SIZE]u8)  {

		buf := #load(`input.txt`, []u8)
		row, col : int
		for c in buf {
			if c == '\n' {
				row += 1
				col = 0
			} else {
				input[row][col] = c
				col += 1
			}
		}
		return
	}

solve :: proc() -> (sum : uint) {

	
	input :=  load()


	for row : int; row < SIZE; row += 1 {
		for col : int; col < SIZE; col += 1 {

			char := input[row][col]
			if char == '.' do continue

			border, area : uint
			defer sum += border * area

			Q := make([dynamic]crd)
			defer {
				for i in Q {
					input[i.row][i.col] = '.'
				}
				delete(Q)
			}
			append(&Q, crd{row, col, {.N=false, .E=false, .S=false, .W=false}})
			input[row][col] = '/'
			area += 1
			
			for i : int; i < len(Q); i += 1 {
				for d in dir {
					//fmt.println(c.row, c.col, d)
					row_, col_, ok := step_and_check(Q[i].row, Q[i].col, d)
					//fmt.println(row_, col_, ok)
					if ok {
						if input[row_][col_] == char {
							append(&Q, crd{row_, col_, {.N=false, .E=false, .S=false, .W=false}})
							input[row_][col_] = '/'
							area += 1
						} else {
							if input[row_][col_] != '/' do Q[i].wall[d] = true
						}
					} else do Q[i].wall[d] = true
				}
			}

			corner: uint
			for c in Q {
				w := c.wall
				for d in dir {
					if w[d] {
						border += 1
						dcw := rotate_clock_wise(d)
						dacw := rotate_anti_clock_wise(d)
						if w[dcw] {
							 corner += 1
							 //fmt.println(c, "inside",d,  "cw")
						}
						else {
							row_, col_, ok :=  step_and_check(c.row, c.col, dcw)
							row_, col_, ok = step_and_check(row_, col_, d)
							if ok {
								if input[row_][col_] == '/' {
									corner += 1
									//fmt.println(c, "outside",d , "cw")
								}
							}
						}
						if w[dacw] {
							corner += 1
							//fmt.println(c, "inside",d , "acw")
						}
						else {
							row_, col_, ok :=  step_and_check(c.row, c.col, dacw)
							row_, col_, ok = step_and_check(row_, col_, d)
							if ok {
								if input[row_][col_] == '/'  {
									corner += 1
									//fmt.println(c, "outside", d , "acw")
								}
							}
						}
					}
				}
			}
			corner /= 2
			border = corner
			fmt.println(area, border, corner, '|', row, col)
			//fmt.println(Q)
			assert(border%2 == 0)
		}
	}
	//fmt.print(input)
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