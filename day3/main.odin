package day3

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

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

	data_string := string(data)
	defer delete(data_string)

	parse_string: string
	defer delete(parse_string)

	mul_sum: int
	stage1: bool
	do_mul := true
	num1: int
	num2: int
	for char, idx in data_string {
		if char == 'd' {
			parse_string, ok = strings.substring(data_string, idx, idx + 4)
			if ok {
				if parse_string == "do()" do do_mul = true
				else {
					parse_string, ok = strings.substring(data_string, idx, idx + 7)
					if ok {
						if parse_string == "don't()" do do_mul = false
					}
				}
			}
		}
		if char == 'm' {
			parse_string, ok = strings.substring(data_string, idx, idx + 4)
			if (ok & do_mul) {
				try_mul: if parse_string == "mul(" {
					stage1 = true
					num1, num2 = 0, 0
					parse_string, ok = strings.substring_from(data_string, idx + 4)
					if ok {
						for char, idx in parse_string {
							if stage1 {
								switch char {
								case '0' ..= '9':
									num1 *= 10
									num1 += int(char) - 48
								case ',':
									if (num1 > 0 && num1 < 1000) do stage1 = false
									else do break try_mul
								case:
									break try_mul
								}
							} else {
								switch char {
								case '0' ..= '9':
									num2 *= 10
									num2 += int(char) - 48
								case ')':
									if (num2 > 0 && num2 < 1000) {
										mul_sum += num1 * num2
									}
									fallthrough
								case:
									break try_mul
								}

							}
						}
					}
				}
			}
		}
	}
	fmt.println(mul_sum)
}
