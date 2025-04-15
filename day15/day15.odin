package day15

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import str "core:strings"
import "core:time"


SIZE :: 50
AREA_CHAR_COUNT :: 51 * 50

State :: enum {
	empty,
	boxl,
	boxr,
	wall,
}
Crd :: distinct [2]int

Pair :: distinct [2]Crd

Direction :: enum {
	N,
	E,
	S,
	W,
}

DirectionVector := [Direction]Crd {
	.N = {-1, 0},
	.E = {0, 1},
	.S = {1, 0},
	.W = {0, -1},
}

area: [SIZE][SIZE * 2]State
robot_dir: Direction
robot_crd: Crd

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
	t := new(time.Stopwatch)
	defer free(t)
	time.stopwatch_start(t)
	fmt.printfln("The answer is: %v ", solve())
	time.stopwatch_stop(t)
	fmt.println(time.stopwatch_duration(t^))
}

solve :: proc() -> (sum: int) {

	input := #load(`input.txt`)
	count: int
	load_area: {
		for row: int; row < SIZE; row += 1 {
			for col: int; col < SIZE * 2; col += 2 {
				switch input[count] {
				case '#':
					area[row][col] = .wall
					area[row][col + 1] = .wall
				case 'O':
					area[row][col] = .boxl
					area[row][col + 1] = .boxr
				case '@':
					robot_crd[0] = row
					robot_crd[1] = col
				}
				count += 1
			}
			count += 1
		}
	}
	fmt.println(area)
	for ; count < len(input); count += 1 {
		switch input[count] {
		case '^':
			robot_dir = .N
		case '>':
			robot_dir = .E
		case 'v':
			robot_dir = .S
		case '<':
			robot_dir = .W
		case:
			continue
		}
		try_push()
	}

	for row: int; row < SIZE; row += 1 {
		for col: int; col < SIZE * 2; col += 1 {
			if area[row][col] == .boxl {
				sum += (100 * row) + col
			}
		}
	}
	return
}
try_push :: proc() {
	blocked: bool = false
	defer if !blocked do robot_crd += DirectionVector[robot_dir]
	c, s := check_next(robot_crd)
	switch s {
	case .empty:
	case .wall:
		blocked = true
	case .boxl:
		blocked = try_push_block(Pair{c, c + DirectionVector[.E]})
	case .boxr:
		blocked = try_push_block(Pair{c + DirectionVector[.W], c})
	}

}

check_next :: proc(c: Crd) -> (Crd, State) {
	c := c
	c += DirectionVector[robot_dir]
	return c, area[c[0]][c[1]]
}

try_push_block :: proc(init: Pair) -> (blocked: bool) {
	q := make([dynamic]Pair)
	defer delete(q)
	append(&q, init)
	defer if !blocked {
		#reverse for p in q {
			l := p[0]
			r := p[1]
			area[l[0]][l[1]] = .empty
			area[r[0]][r[1]] = .empty
			l += DirectionVector[robot_dir]
			r += DirectionVector[robot_dir]
			area[l[0]][l[1]] = .boxl
			area[r[0]][r[1]] = .boxr
		}
	}
	switch robot_dir {
	case .N, .S:
		for p in q {
			for c in p {
				c_, s := check_next(c)
				switch s {
				case .empty:
				case .wall:
					return true
				case .boxl:
					append(&q, Pair{c_, c_ + DirectionVector[.E]})
				case .boxr:
					append(&q, Pair{c_ + DirectionVector[.W], c_})
				}
			}
		}
	case .E:
		for p in q {
			c, s := check_next(p[1])
			switch s {
			case .empty:
			case .wall:
				return true
			case .boxl:
				append(&q, Pair{c, c + DirectionVector[.E]})
			case .boxr:
				assert(false)
			}
		}
	case .W:
		for p in q {
			c, s := check_next(p[0])
			switch s {
			case .empty:
			case .wall:
				return true
			case .boxr:
				append(&q, Pair{c + DirectionVector[.W], c})
			case .boxl:
				assert(false)
			}
		}
	}
	return false
}
