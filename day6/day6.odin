package day6

import "core:fmt"
import "core:os"
import "core:mem"
import "core:strconv"
import str "core:strings"

Coord :: [2]int
Direction :: enum { 
	N,E,S,W 
}

SIZE :: 130

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

	transversed : [SIZE][SIZE]bool
	obstacle : [SIZE][SIZE]bool
	fst_coord : Coord
	cr_coord : Coord
	cr_dir : Direction = .N

	row, col : int
	for char in data {
		if char == '\n' {
			row += 1
			col = 0
			continue
		}
		switch char {
			case '#' : obstacle[row][col] = true
			case '^' : {
				fst_coord = Coord{row, col}
			}
		}
		col += 1
	}

	cr_coord = fst_coord
	loop : for {
		fmt.println(cr_coord)
		next_coord : int
		switch cr_dir {
			case .N : {
				#reverse for c,idx in obstacle[:cr_coord[0]] {
					if c[cr_coord[1]] == true {
						next_coord := cr_coord[0] - (len(obstacle[:cr_coord[0]]) - (idx + 1))
						for &c2 in transversed[next_coord:cr_coord[0] + 1] {
							c2[cr_coord[1]] = true
						}
						cr_dir = .E
						cr_coord[0] = next_coord
						continue loop
					}
				}
				for &c in transversed[:cr_coord[0] + 1] {
					c[cr_coord[1]] = true
				}
				break loop
			}
			case .E : {
				for c,idx in obstacle[cr_coord[0]][cr_coord[1] + 1:] {
					if c == true {
						next_coord := cr_coord[1] + idx
						for &c2 in transversed[cr_coord[0]][cr_coord[1]:next_coord + 1]{
							c2 = true
						}
						cr_dir = .S
						cr_coord[1] = next_coord
						continue loop
					}
				}
				for &c in transversed[cr_coord[0]][cr_coord[1]:] {
					c = true
				}
				break loop
			}
			case .S : {
				for c,idx in obstacle[cr_coord[0] + 1:] {
					if c[cr_coord[1]] == true {
						next_coord := cr_coord[0] + idx
						for &c2 in transversed[cr_coord[0]:next_coord + 1] {
							c2[cr_coord[1]] = true
						}
						cr_dir = .W
						cr_coord[0] = next_coord
						continue loop
					}
				}
				for &c in transversed[cr_coord[0]:] {
					c[cr_coord[1]] = true
				}
				break loop
			}
			case .W : {
				#reverse for c,idx in obstacle[cr_coord[0]][:cr_coord[1]] {
					if c == true {
						next_coord := cr_coord[1] - (len(obstacle[cr_coord[0]][:cr_coord[1]]) - (idx + 1))
						for &c2 in transversed[cr_coord[0]][next_coord:cr_coord[1]+1]{
							c2 = true
						}
						cr_dir = .N
						cr_coord[1] = next_coord
						continue loop
					}
				}
				for &c in transversed[cr_coord[0]][:cr_coord[1] + 1] {
					c = true
				}
				break loop
			}
		}
	}
	count : int
	for c in transversed {
		for c2 in c {
			if c2 do count += 1
		}
	}
	loopcount := 0
	fmt.println(count)
	for c, row in transversed {
		for c2, col in c {
			if c2 {
				obstacle[row][col] = true
				defer obstacle[row][col] = false
				cr_coord = fst_coord
				cr_dir = .N
				count := 0
				loop2 : for {
					count += 1
					if count > SIZE * SIZE {
						loopcount += 1
						break loop2
					}
					next_coord : int
					switch cr_dir {
						case .N : {
							#reverse for c,idx in obstacle[:cr_coord[0]] {
								if c[cr_coord[1]] == true {
									next_coord := cr_coord[0] - (len(obstacle[:cr_coord[0]]) - (idx + 1))
									for &c2 in transversed[next_coord:cr_coord[0] + 1] {
										c2[cr_coord[1]] = true
									}
									cr_dir = .E
									cr_coord[0] = next_coord
									continue loop2
								}
							}
							for &c in transversed[:cr_coord[0] + 1] {
								c[cr_coord[1]] = true
							}
							break loop2
						}
						case .E : {
							for c,idx in obstacle[cr_coord[0]][cr_coord[1] + 1:] {
								if c == true {
									next_coord := cr_coord[1] + idx
									for &c2 in transversed[cr_coord[0]][cr_coord[1]:next_coord + 1]{
										c2 = true
									}
									cr_dir = .S
									cr_coord[1] = next_coord
									continue loop2
								}
							}
							for &c in transversed[cr_coord[0]][cr_coord[1]:] {
								c = true
							}
							break loop2
						}
						case .S : {
							for c,idx in obstacle[cr_coord[0] + 1:] {
								if c[cr_coord[1]] == true {
									next_coord := cr_coord[0] + idx
									for &c2 in transversed[cr_coord[0]:next_coord + 1] {
										c2[cr_coord[1]] = true
									}
									cr_dir = .W
									cr_coord[0] = next_coord
									continue loop2
								}
							}
							for &c in transversed[cr_coord[0]:] {
								c[cr_coord[1]] = true
							}
							break loop2
						}
						case .W : {
							#reverse for c,idx in obstacle[cr_coord[0]][:cr_coord[1]] {
								if c == true {
									next_coord := cr_coord[1] - (len(obstacle[cr_coord[0]][:cr_coord[1]]) - (idx + 1))
									for &c2 in transversed[cr_coord[0]][next_coord:cr_coord[1]+1]{
										c2 = true
									}
									cr_dir = .N
									cr_coord[1] = next_coord
									continue loop2
								}
							}
							for &c in transversed[cr_coord[0]][:cr_coord[1] + 1] {
								c = true
							}
							break loop2
						}
					}
				}
			}
		}
	}
	fmt.println(loopcount)
}
