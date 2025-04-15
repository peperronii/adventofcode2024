package day8

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import str "core:strings"

SIZE :: 50
Crd :: [2]int

crd_is_inside :: proc(c:Crd) -> bool {

	if c.x >= 0 && c.x < SIZE {
		if c.y >= 0 && c.y < SIZE {
			return true
		}
	}

	return false
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


	data, ok := os.read_entire_file(`./input.txt`)
	defer delete(data)
	assert(ok == true)

	row : int
	col : int
	antinode : [SIZE][SIZE]bool
	antenna : map[byte][dynamic]Crd
	defer {
		for key in antenna {
			delete(antenna[key])
		}
		delete(antenna)
	}
	

	read_data : for char in data {

		if char == '\n' {
			row += 1
			col = 0
			continue
		}

		if char != '.' {

			have_key := false

			for key in antenna {
				if key == char {
					have_key = true
					break
				}
			}

			if !have_key {
				antenna[char] = make([dynamic]Crd)
			}

			append(&antenna[char], Crd{row, col})
		}
		col += 1

		for key in antenna {
			for c1, idx in antenna[key] {
				for c2 in antenna[key][idx + 1:] {
					antinode[c1[0]][c1[1]] = true
					antinode[c2[0]][c2[1]] = true
					diff := c2 - c1
					buf_c1 := c1 - diff
					for crd_is_inside(buf_c1) {
						antinode[buf_c1[0]][buf_c1[1]] = true
						buf_c1 -= diff
					}
					buf_c2 := c2 + diff
					for crd_is_inside(buf_c2) {
						antinode[buf_c2[0]][buf_c2[1]] = true
						buf_c2 += diff
					}
				}
			}
		}
	}
	antinode_count := 0
	for row in antinode {
		for col in row {
			if col do antinode_count += 1
		}
	}
	fmt.println(antinode_count)
}
