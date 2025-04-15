package main
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
print :: fmt.println

main :: proc() {
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
    print("Start")
    print("Problem 2: ", solve(2))
    print("End")
}

split_int :: proc(rock : int) -> (int, int) {
    digits := digit_count(rock)
    num_left := rock
    n := 1
    for i in 0..<digits/2 {
        num_left /= 10
        n *= 10
    }

    num_right := rock - num_left * n
    return num_left, num_right
}

digit_count :: proc(rock : int) -> int {
    digits := 0
    for r := rock; r > 0; r = r / 10 do digits += 1
    return digits
}

blink_rock :: proc(rock : int) -> (split : bool, a : int, b : int){
    if rock == 0 do return false, 1, 0

    digits := digit_count(rock)
    if digits % 2 == 0 {
        a, b := split_int(rock)
        return true, a, b
    }
    return false, rock * 2024, 0
}

solve :: proc(problem : int) -> int {
    rocks : map[int]int
    defer delete(rocks)
    input := #load("./input.txt", string)
    for s_rock in strings.split_iterator(&input, " ") {
        rock := strconv.parse_int(s_rock) or_continue
        rocks[rock] = 1
    }

    for _ in 0..<75 {
        // double buffer to get our rocks off
        last_rocks : map[int]int
        defer delete(last_rocks)
        for k, v in rocks do last_rocks[k] = v
        clear(&rocks)

        for rock, num in last_rocks {
            split, a, b := blink_rock(rock)
            rocks[a] += 1 * num
            if split do rocks[b] += 1 * num
        }
    }

    total := 0
    for k, v in rocks do total += v
    return total
}