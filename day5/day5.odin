package day5

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import str "core:strings"

Pair :: struct {
	before: int,
	after: int
}

bubble_sort_together :: proc(lead, follow : []int) {
	swapped := false
	for _, idx in lead {
		if idx == 0 do continue
		if lead[idx] > lead[idx - 1] {
			lead[idx], lead[idx - 1] = lead[idx - 1], lead[idx]
			follow[idx], follow[idx - 1] = follow[idx - 1], follow[idx]
			swapped = true
		}
	}
	if swapped do bubble_sort_together(lead[:], follow[:])
}

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
	defer delete(data)
	assert(ok == true)

	st := string(data)
	rules : [dynamic]Pair
	defer delete(rules)
	update := false
	mid_sum := 0
	for line in str.split_lines_iterator(&st) {

		if update {
			buf_line := line
			pages : [dynamic]int
			defer delete(pages)

			for num in str.split_iterator(&buf_line, ",") {
				n,_ := strconv.parse_int(num)
				append(&pages, n)
			}

			before_order : [dynamic]int
			defer delete(before_order)
			resize(&before_order, len(pages))

			wrong := false
			for page, idx in pages {
				for rule in rules {
					if rule.before == page {
						for after_page, after_idx in pages {
							if rule.after == after_page {
								before_order[idx] += 1
								if idx > after_idx do wrong = true
							}
						}
					}
				}
			}

			if wrong {
				bubble_sort_together(before_order[:],pages[:])
				mid_sum += pages[len(pages) / 2]
			}




		} else if line == "" {

			update = true

		} else {

			buf_pair : Pair
			buf_str := str.split(line, "|")
			defer delete(buf_str)
			buf_pair.before, _ = strconv.parse_int(buf_str[0])
			buf_pair.after, _ = strconv.parse_int(buf_str[1])
			append(&rules, buf_pair)

		}
	}
	fmt.println(mid_sum)
}






