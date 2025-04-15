package day16

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import str "core:strings"
import "core:time"

SIZE :: 141
State :: enum {
	start,
	end,
	path,
	wall,
}

Dir :: enum {
	N,
	E,
	S,
	W,
}

DirVec := [Dir][2]int {
	.N = {-1, 0},
	.E = {0, 1},
	.S = {1, 0},
	.W = {0, -1},
}

rotate_cw :: proc(d: Dir) -> Dir {
	return Dir((int(d) + 1) % 4)
}

rotate_acw :: proc(d: Dir) -> Dir {
	return Dir((int(d) + 3) % 4)
}

Turn :: struct {
	pos:   [2]int,
	depth: int,
	step:  int,
	dir:   Dir,
}

State_or_Passed :: union {
	State,
	int,
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
	t := new(time.Stopwatch)
	defer free(t)
	time.stopwatch_start(t)
	if ans, ok := solve(); ok {
		fmt.println("The answer is : ", ans)
	} else do fmt.println("Error")
	time.stopwatch_stop(t)
	fmt.println(time.stopwatch_duration(t^))
}

area: [SIZE][SIZE]State_or_Passed
start: [2]int
end: [2]int


solve :: proc() -> (sum: int, ok: bool) {

	input := #load(`input.txt`)
	load_area: {
		count: int
		for row: int; row < SIZE; row += 1 {
			for col: int; col < SIZE; col += 1 {
				switch input[count] {
				case '#':
					area[row][col] = .wall
				case '.':
					area[row][col] = .path
				case 'S':
					area[row][col] = .start
					start = {row, col}
				case 'E':
					area[row][col] = .end
					end = {row, col}
				}
				count += 1
			}
			count += 1
		}
	}

	// BFS,
	q := make([dynamic]Turn)
	defer delete(q)
	append(&q, Turn{pos = start, dir = .E})
	for {
		t := pop_front_safe(&q) or_break
		fmt.println(t)
		for {
			p := t.pos
			switch type in area[p.x][p.y] 
			{
			case State:
				if area[p.x][p.y] == .end do break
				if area[p.x][p.y] == .wall do break
				p = t.pos + DirVec[rotate_cw(t.dir)]
				if area[p.x][p.y] == .path do append(&q, Turn{pos = p, dir = rotate_cw(t.dir), depth = t.depth + 1, step = t.step + 1})
				p = t.pos + DirVec[rotate_acw(t.dir)]
				if area[p.x][p.y] == .path do append(&q, Turn{pos = p, dir = rotate_acw(t.dir), depth = t.depth + 1, step = t.step + 1})
				area[t.pos.x][t.pos.y] = (t.depth * 1000) + t.step
				t.pos += DirVec[t.dir]
				t.step += 1
		}
	}
	return 0, false
}
