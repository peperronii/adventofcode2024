package day10

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import str "core:strings"

SIZE :: 48

inside :: proc(row, col : int) -> bool {
	if (row >= 0) && (row < SIZE) && (col >= 0) && (col < SIZE) do return true
	return false
} 

hike :: proc(row, col : int , trail : [48][48]int, sum : ^int ) {
	elevation := trail[row][col]
	if elevation == 9 {
		sum^ += 1
	} else {
		if inside(row + 1, col) {
			n := trail[row + 1][col]
			if n == elevation + 1 do hike(row + 1, col, trail, sum)
		}
		if inside(row - 1, col) {
			n := trail[row - 1][col]
			if (n == elevation + 1) do hike(row - 1, col, trail, sum)
		}
		if inside(row, col + 1) {
			n := trail[row][col + 1]
			if (n == elevation + 1) do hike(row, col + 1, trail, sum)
		}
		if inside(row, col - 1) {
			n := trail[row][col - 1]
			if (n == elevation + 1) do hike(row, col - 1, trail, sum)
			
		}
	}
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
	
	sum : int
	trail : [SIZE][SIZE]int

	format: {
		row, col : int
		for b in data {
			if b == '\n' {
				row += 1
				col = 0
			} else {
				trail[row][col] = int(b-48)
				col += 1
			}
		}
	}
	for row := 0; row < SIZE ; row += 1 {
		for col := 0; col < SIZE ; col += 1 {
			if trail[row][col] != 0 do continue
			hike(row,col,trail,&sum)
		}
	}
	fmt.println(sum)
}