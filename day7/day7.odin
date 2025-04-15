package day7

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import str "core:strings"

concatenate :: proc(fst, snd : u128) -> u128 {
	mul : u128 = 10
	buf_snd := snd
	for {
		if buf_snd < 10 do break
		buf_snd /= 10
		mul *= 10
	}
	
	return ((fst * mul ) + snd)

}


go_fish :: proc(target, val: u128, ar: []u128, lvl: u128) -> bool {

	if lvl == u128(len(ar)) - 1 do return val == target

	if val > target do return false

	try_mul := go_fish(target, val * ar[lvl + 1], ar[:], lvl + 1)
	if try_mul do return true

	try_add := go_fish(target, val + ar[lvl + 1], ar[:], lvl + 1)
	if try_add do return true

	try_concat := go_fish(target, concatenate(val, ar[lvl + 1]), ar[:], lvl + 1)
	if try_concat do return true

	return false

}

main :: proc() {

	fmt.println(concatenate(20,10))
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

	data, ok := os.read_entire_file(`./input.txt`)
	defer delete(data)
	assert(ok == true)

	sum, target: u128
	ar : [dynamic]u128
	defer delete(ar)

	it := string(data)
	for line in str.split_lines_iterator(&it) {
		buf_string := str.split(line, ":")
		defer delete(buf_string)
		target = strconv.parse_u128(buf_string[0]) or_break  
		for num in str.split_iterator(&buf_string[1]," ") {
			if num == "" do continue
			append(&ar, strconv.parse_u128(num) or_break)
		}
		if go_fish(target, ar[0], ar[:], 0) do sum += target
		clear(&ar)
	}

	fmt.println(sum)

}
