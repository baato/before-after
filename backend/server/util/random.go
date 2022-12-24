package util

import (
	"math/rand"
	"strings"
)

const unicode_chars = "abcdefghijkalmnopqrstuvwxyzABCDEFGHIJKLAMNOPQRSTUVWXYZ123456789"

func RandomState() string {
	var sb strings.Builder
	k := len(unicode_chars)
	for i := 0; i < 48; i++ {
		c := unicode_chars[rand.Intn(k)]
		sb.WriteByte(c)
	}

	return sb.String()
}
