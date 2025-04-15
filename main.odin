package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

is_safe :: proc(array: []int, tolerate: bool = true, blind: int = 0) -> (safe: bool = true) {
	buf_array := slice.clone_to_dynamic(array)
	defer delete(buf_array)
	if (!tolerate) do ordered_remove(&buf_array, blind)

	for num, idx in buf_array {
		if idx == 0 do continue
		buf_array[idx - 1] = buf_array[idx] - buf_array[idx - 1]
	}
	pop(&buf_array)
	// check range and zeros
	for num in buf_array {
		if safe == false do break
		switch num {
		case -3 ..= -1, 1 ..= 3:
			break
		case:
			safe = false
		}
	}
	// check momentum
	for _, idx in buf_array {
		if safe == false do break
		if idx == 0 do continue
		if (buf_array[idx] > 0) ~ (buf_array[idx - 1] > 0) do safe = false
	}
	if ((safe == false) & tolerate) {
		for _, idx in array {
			if safe == true do break
			safe = is_safe(array, false, idx)
		}
	}
	return
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
	}

	data, ok := os.read_entire_file(`input.txt`)
	defer delete(data)
	assert(ok == true)
	it := string(data)
	buf_array: [dynamic]int
	defer delete(buf_array)
	buf_line: string
	safe: int

	for line in strings.split_lines_iterator(&it) {
		buf_line = line
		for num in strings.split_iterator(&buf_line, " ") {
			append(&buf_array, strconv.atoi(num))
		}
		if is_safe(buf_array[:]) do safe += 1
		clear(&buf_array)
	}
	fmt.println(safe)

}
