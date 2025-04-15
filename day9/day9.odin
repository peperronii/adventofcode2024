package day9

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import "core:slice"
import str "core:strings"

File :: struct {
	size : uint,
	id : uint,
	moved : bool
}

Block :: uint

File_or_Block :: union {
	File,
	Block
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
	drive : [dynamic]File_or_Block
	defer delete(drive)

	for num,idx in data {
		n := uint(num-48)
		if idx % 2 == 0 do append(&drive, File{n, uint(idx/2), false})
		else do append(&drive, Block(n))
	}
	length : uint = 0
	for d in drive {
		switch f in d {
			case File:
				length += f.size
			case Block:
				length += f
		}
	}
	fmt.println(length)
	file: for ridx := len(drive) - 1 ; ridx >= 0; ridx -= 1 {
		#partial switch f in drive[ridx] {
			case File:
				if f.moved do continue file
				loop: for idx := 0 ; idx < ridx ; idx += 1 {
					#partial switch b in drive[idx] {
						case Block:
							if b >= f.size {
								inject_at(&drive, idx + 1, b - f.size)
								buf := f
								buf.moved = true
								ridx += 1
								drive[idx], drive[ridx] = buf, f.size
								break loop
							}
					}
				}
		}
	}

	idx :uint = 0
	sum :uint = 0
	length = 0
	for d in drive {
		switch f in d {
			case File:
				length += f.size
			case Block:
				length += f
		}
	}
	for d in drive {
		switch f in d {
			case File: 
				for i := 0 ; uint(i) < f.size ; i += 1 {
					sum += idx * f.id
					idx += 1
				}
			case Block: {
				for i := 0 ; uint(i) < f ; i += 1 {
					idx += 1
				}
			}
		}
	}
	fmt.println(sum)
	fmt.println(length)
	//fmt.println(drive)
}
//20217070065626

