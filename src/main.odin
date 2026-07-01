package main

import "core:fmt"
import "core:os"

main :: proc() {

	paramArray: [dynamic]^Param
	paramExpected: ParamType
	defer delete(paramArray)

	Param_Init(&paramArray)
	defer Param_Clear(&paramArray)

	args := os.args[1:]

	for i in 0 ..< len(args) {
		paramExpected, matchAt := Param_Match(&paramArray, args[i])
		#partial switch (paramExpected) {
		case .APPNAME:
			paramArray[matchAt].content = args[i + 1]
		case .TIME:
			paramArray[matchAt].content = args[i + 1]
		case .URGENCY:
			paramArray[matchAt].content = args[i + 1]
		case .NONE:
			switch (len(args[i:])) {
			case 0:
				fmt.eprintln("Requires message")
				os.exit(1)
			case 1:
				ptitle := Param_Get_With_Tag(&paramArray, "title")
				ptitle.content = args[i]
				break
			}
		}
	}

	ptitle := Param_Get_With_Tag(&paramArray, "title")
	if os.is_tty(os.stdin) {
		fmt.println(ptitle.content)
	} else {

		command: [dynamic]string
		defer delete(command)
		append(&command, "notify-send")

		append(&command, "-a")
		default_appname := "center-text"
		pappname := Param_Get_With_Tag(&paramArray, "appname")
		if pappname.content != "" {
			append(&command, pappname.content)
		} else {
			append(&command, default_appname)
		}

		append(&command, "-u")
		default_urgency := "low"
		purgency := Param_Get_With_Tag(&paramArray, "urgency")
		if purgency.content != "" {
			append(&command, purgency.content)
		} else {
			append(&command, default_urgency)
		}

		append(&command, "-t")
		default_time := "2000"
		ptime := Param_Get_With_Tag(&paramArray, "time")
		if ptime.content != "" {
			append(&command, ptime.content)
		} else {
			append(&command, default_time)
		}

		append(&command, ptitle.content)

		pd := new(os.Process_Desc)
		defer free(pd)

		pd.command = command[:]
		_, _, _, _ = os.process_exec(pd^, context.allocator)

	}

}
