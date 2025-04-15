package linkedlist

import "core:fmt"
import "core:mem"

Node :: struct {
    number : int,
    next: ^Node,
}

linked_list_init :: proc(num: int) -> (root: ^Node) {
    root = new(Node)
    root.number = num
    return
}

add_to_linked_list :: proc(node: ^Node, num: int) -> (ok: bool) {
    if node.next == nil {
        node.next = new(Node)
        node.next.number = num
        return true
    }
    else do return add_to_linked_list(node.next, num)
}

delete_linked_list :: proc(node: ^Node) -> (ok: bool) {
    if node.next == nil {
        free(node)
        return true
    }
    else {
        delete_linked_list(node.next)
        free(node)
        return true
    }
}

print_linked_list :: proc(node: ^Node) {
    fmt.println(node.number)
    if node.next == nil {
    return
    }
    else do print_linked_list(node.next)
}

main :: proc(){
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
    root := linked_list_init(0)
    add_to_linked_list(root, 1)
    print_linked_list(root)
    delete_linked_list(root)
}
