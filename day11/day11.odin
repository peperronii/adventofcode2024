package day11

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import str "core:strings"



split :: proc(num, digit : uint) -> (f, s: uint) {
	buf :uint = 1
	for idx in 1..=digit/2 {
		buf *= 10
	}
	f = num / buf
	s = num - (f * buf)
	return
}

digit :: proc(x: uint) -> uint {
	x := x
	count :uint = 1
	for {
		if x < 10 do break
		x /= 10
		count += 1
	}
	return count
}



main :: proc() {
	//set tracking allocator
	default_allocator := context.allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, default_allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	defer {
		for _, value in tracking_allocator.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
		}
		for b in tracking_allocator.bad_free_array {
			fmt.printf("Bad Free : %v", b)
		}
	}

	data := #load("./input.txt", string)
	stones : [dynamic]uint
	defer delete(stones)
	for s in str.split_iterator(&data, " ") {
		n,_ := strconv.parse_uint(s)
		append(&stones, n)
	}
	sum :uint
	for stone in stones {
		buf := [dynamic]uint{stone}
		defer delete(buf)
		n_buf  : [dynamic]uint
		defer delete(n_buf)
		for _ in 1..=25 {
			for s in buf {
				if s == 0 do append(&n_buf, 1)
				else {
					d := digit(s)
					if d % 2 == 0 {
						append(&n_buf, split(s,d))
					} else {
						append(&n_buf, s * 2024)
					}
				}
			}
			clear(&buf)
			append(&buf, ..n_buf[:])
			clear(&n_buf)
			//fmt.println(buf)
		}
		sum += len(buf)
		//fmt.println(sum)
	}
	fmt.println(sum)
}