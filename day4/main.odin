package day4

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Array_Iterator :: struct($T: typeid){
	idx : u32,
	array : []T
}

array_iterator_init :: proc(data: $T/[]$E) -> (it: ^Array_Iterator(E)) {
	it = new(Array_Iterator(E))
	it.idx = 0
	it.array = data
	return
}

array_iterator_iter :: proc(it: ^$I/Array_Iterator($E)) -> (value: E) {
	value = it.array[it.idx]
	it.idx += 1
	return
}

is_inside :: proc(x: int) -> bool {
	return true if (x < 140) && (x >= 0) else false
}

shift_array :: proc(array: $T/[]$E) {
	buf := array[0]
	for &elem, idx in array {
		if idx == len(array) - 1 do elem = buf
		else do elem = array[idx + 1]
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
	assert(ok == true)
	it := array_iterator_init(data[:])
	mat :[140][140]byte
	for row := 0; row < 140; row += 1 {
		for col := 0; col < 140; col += 1 {
			mat[row][col] = array_iterator_iter(it)
			if mat[row][col] == '\n' do mat[row][col] = array_iterator_iter(it)
		}
	}
	fmt.println(mat)
	delete(data)
	free(it)

	xmas_count : int
	MAS :: [4]byte{'M','M','S','S'}
	for row := 0; row < 140; row += 1 {
		for col := 0; col < 140; col += 1 {
			if mat[row][col] == 'A' {
				idx := 0
				buf := [4]byte{}
				for drow := -1; drow <= 1; drow += 2 {
					for dcol := drow; dcol <= 1 &&  dcol >= -1; dcol -= (drow * 2){
						if (drow == 0) && (dcol == 0) do continue
							row2 := row + drow
							col2 := col + dcol
							is_inside(row2) or_break
							is_inside(col2) or_break
							buf[idx] = mat[row2][col2]
							idx += 1
					}
				}
				for i := 0; i < 4; i += 1 {
					fmt.println(buf)
					if buf == MAS {
						xmas_count += 1
						fmt.println("XMAS!")
						break
					}
					shift_array(buf[:])
				}
			}
		}
	}
	fmt.println(xmas_count)
}


