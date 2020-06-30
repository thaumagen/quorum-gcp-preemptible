package main

import (
	"math/rand"
	"time"
)

// Thanks to https://blog.gopheracademy.com/advent-2014/backoff/

// BackoffPolicy implements a backoff policy, randomising its delays
// and saturating at the final value in Millis.
type BackoffPolicy struct {
	Millis []int
}

// DefaultBackoff is a backoff policy ranging up to 50 seconds.
var DefaultBackoff = BackoffPolicy{
	[]int{0, 10, 10, 100, 100, 500, 500, 3000, 3000, 5000, 10000, 25000, 50000},
}

// Duration returns the time duration of the n'th wait cycle in a
// backoff policy. This is b.Millis[n], randomized to avoid thundering
// herds.
func (b BackoffPolicy) Duration(n int) time.Duration {
	if n >= len(b.Millis) {
		n = len(b.Millis) - 1
	}

	return time.Duration(jitter(b.Millis[n])) * time.Millisecond
}

// jitter returns a random integer uniformly distributed in the range
// [0.5 * millis .. 1.5 * millis]
func jitter(millis int) int {
	if millis == 0 {
		return 0
	}

	return millis/2 + rand.Intn(millis)
}
