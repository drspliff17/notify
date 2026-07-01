package main

import "core:fmt"
import "core:slice"

Param :: struct {
	content: string,
	tag:     string,
	alias:   []string,
}

ParamType :: enum {
	NONE,
	TITLE,
	APPNAME,
	TIME,
	URGENCY,
}

// Initalise all param structs, and update given array
Param_Init :: proc(paramArray: ^[dynamic]^Param) {
	p_title := Param_Create()
	p_title.tag = "title"
	append(paramArray, p_title)

	p_appname := Param_Create()
	p_appname.tag = "appname"
	p_appname.alias = slice.clone([]string{"-a", "--appname"})
	append(paramArray, p_appname)

	p_time := Param_Create()
	p_time.tag = "time"
	p_time.alias = slice.clone([]string{"-t", "--time"})
	append(paramArray, p_time)

	p_urgency := Param_Create()
	p_urgency.tag = "urgency"
	p_urgency.alias = slice.clone([]string{"-u", "--urgency"})
	append(paramArray, p_urgency)
}

// Deallocate all Param structs inside given array
Param_Clear :: proc(paramArray: ^[dynamic]^Param) {
	for i in 0 ..< len(paramArray) {
		Param_Destroy(paramArray[i])
	}
}

// Allocates new Param struct, and returns pointer
Param_Create :: proc() -> ^Param {
	p, err := new(Param)
	if err != nil do fmt.panicf("Could not allocate Param: %v", err)
	return p
}

// Deallocates param struct, by passed pointer
Param_Destroy :: proc(p: ^Param) {
	free(p)
}

Param_Match :: proc(params: ^[dynamic]^Param, input: string) -> (expected: ParamType, index: int) {
	for i in 0 ..< len(params) {
		for alias in params[i].alias {
			if input == alias {
				switch (params[i].tag) {
				case "appname":
					return .APPNAME, i

				case "time":
					return .TIME, i

				case "urgency":
					return .URGENCY, i

				case:
					return .NONE, i
				}
			}
		}
	}
	return nil, -1
}

Param_Get_With_Tag :: proc(params: ^[dynamic]^Param, tag: string) -> ^Param {
	for i in 0 ..< len(params) {
		if params[i].tag == tag {
			return params[i]
		}
	}
	return nil
}
