package day17

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import str "core:strings"
import "core:time"

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
	solve()
	time.stopwatch_stop(t)
	fmt.println(time.stopwatch_duration(t^))
}

A, B, C: uint = 30344604, 0, 0
program := [?]u8{2, 4, 1, 1, 7, 5, 1, 5, 4, 5, 0, 3, 5, 5, 3, 0}
instruction_pointer: uint = 0
output := make([dynamic]uint)
literal_operand := [8]uint{0, 1, 2, 3, 4, 5, 6, 7}
combo_operand := [8]^uint {
	&literal_operand[0],
	&literal_operand[1],
	&literal_operand[2],
	&literal_operand[3],
	&A,
	&B,
	&C,
	nil,
}
opcode := [8]proc(operand: u8) -> (jumped: bool){adv, bxl, bst, jnz, bxc, out, bdv, cdv}

solve :: proc() {
	for (instruction_pointer < len(program)) {
		jumped := opcode[program[instruction_pointer]](program[instruction_pointer + 1])
		if !jumped do instruction_pointer += 2
		fmt.printfln("%b %b %b | %i %i %i", A, B, C, A, B, C)
	}
	fmt.println(output)
	fmt.println(A, B, C)
	delete(output)
}

adv :: proc(operand: u8) -> (jumped: bool) {
	denominator: uint = 1
	for _ in 0 ..< combo_operand[operand]^ {
		denominator *= 2
	}
	A = A / denominator
	return
}

bxl :: proc(operand: u8) -> (jumped: bool) {
	B ~= literal_operand[operand]
	return
}

bst :: proc(operand: u8) -> (jumped: bool) {
	B = combo_operand[operand]^ % 8
	return
}

jnz :: proc(operand: u8) -> (jumped: bool) {
	if A != 0 {
		instruction_pointer = literal_operand[operand]
		jumped = true
	}
	return
}

bxc :: proc(operand: u8) -> (jumped: bool) {
	_ = operand
	B ~= C
	return
}

out :: proc(operand: u8) -> (jumped: bool) {
	append(&output, combo_operand[operand]^ % 8)
	return
}

bdv :: proc(operand: u8) -> (jumped: bool) {
	denominator: uint = 1
	for _ in 0 ..< combo_operand[operand]^ {
		denominator *= 2
	}
	B = A / denominator
	return
}

cdv :: proc(operand: u8) -> (jumped: bool) {
	denominator: uint = 1
	for _ in 0 ..< combo_operand[operand]^ {
		denominator *= 2
	}
	C = A / denominator
	return
}
