package day13

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import "core:time"
import str "core:strings"
testinput :: `Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279

`

get_ints :: proc( s : string )  -> (x,y : int) {
	start, count : int
	second_phase, in_num : bool
	for r in s {
		switch r {
			case '0'..='9' :
				if second_phase {
					y, _= strconv.parse_int(s[count:])
					return
				}
				else if !in_num {
					in_num = true
					start = count
				}
			case : if in_num {
				second_phase = true
				x, _ = strconv.parse_int(s[start: count + 1])
			}
		}
		count += 1
	}
	return
}



solve :: proc() -> (sum : uint) {
	
	input :=  #load(`input.txt`, string)
	//input := testinput
	iter := input
	x,y,xa,xb,ya,yb,count: int
	loop: for line in str.split_lines_iterator(&iter) {
		switch count {
			case 0 : 
				xa,_ = strconv.parse_int(line[12:14])
				ya,_ = strconv.parse_int(line[18:20])
				//fmt.println(xa, ya)
			case 1 : 
				xb,_ = strconv.parse_int(line[12:14])
				yb,_ = strconv.parse_int(line[18:20])		
				//fmt.println(xb, yb)
			case 2 : 
				x, y = get_ints(line)
				x += 10000000000000
				y += 10000000000000
			//fmt.println(x, y)

			case 3 : {
				count = -1
				denomenator := (ya * xb) - (xa * yb)
				a_numerator := (y * xb) - (x * yb)
				b_numerator := (x * ya ) - (y * xa)
				a := a_numerator/denomenator if a_numerator % denomenator == 0 else -1
				b := b_numerator/denomenator if b_numerator % denomenator == 0 else -1
				if a >= 0 && b >= 0 {
					//fmt.println(a, b)
					sum += uint((a*3) + b)
				}
			}
		}
		count += 1
	}
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