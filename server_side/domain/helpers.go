package domain

import (
	"fmt"
	"reflect"
)

func SafeCast[T any](param any) (T, error) {
	var getT T

	if param == nil {
		return getT, fmt.Errorf("cast error: got nil param")
	}

	v, ok := param.(T)
	if !ok {
		return v, fmt.Errorf("cast error: got type: %s, want type: %s", reflect.TypeOf(param).String(), reflect.TypeOf(getT).String())
	}

	return v, nil
}
