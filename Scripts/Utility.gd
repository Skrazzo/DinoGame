extends Node

func better_print_stack(start: int = 0):
	var stack = get_stack();
	var offset = 1 + start;
	for i in range(offset, len(stack)):
		print("Frame ", i - offset, " - ", stack[i].source, ":", stack[i].line, " in function '", stack[i].function, "'");

func proper_assert(assertion: bool, message: String=""):
	if(OS.is_debug_build()):
		assert(assertion, message);
	elif(!assertion):
		printerr("Assertion failed: ", message);
		better_print_stack(1);
		get_tree().quit();

# I love when languages only provide length based substring functions, don't you?
func proper_substring(str: String, start: int, end: int = str.length()): # non inclusive
	return str.substr(start, end - start);
