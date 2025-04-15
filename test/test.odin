package day16

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import str "core:strings"
import "core:time"

Dir :: enum {
	n,
	e,
	s,
	w,
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
}
