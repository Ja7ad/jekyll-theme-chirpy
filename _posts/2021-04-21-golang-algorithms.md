---
title: Golang Algorithms Code
author: Javad Rajabzade
date: 2021-04-21 14:33:00 +0800
categories: [Golang, Codes]
tags: [golang, go, algorithms, codes]
math: false
mermaid: false
image:
  src: https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-algorithms.png
---

# Search Algorithms
---

## Binary search

```go
package main

import (
    "fmt"
    "time"
)

//works when the array is sorted
func binarySearch(arr []int, x int) int {
    i := 0
    j := len(arr)
    for i != j {
        var m = (i + j) / 2
        if x == arr[m] {
            return m
        }
        if x < arr[m] {
            j = m
        } else {
            i = m + 1
        }
    }
    return -1
}

func main() {
    items := []int{2, 3, 5, 7, 11, 13, 17}

    fmt.Println(binarySearch(items, 1))
    //print -1
    fmt.Println(binarySearch(items, 7))
    //print 3
    fmt.Println(binarySearch(items, 19))
    //print -1

    // *** simplified speed test ***

    items = make([]int, 10000000)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    count := 100

    start := time.Now()

    for i := 0; i < count; i++ {
        binarySearch(items, 7777777)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds() / int64(count)

    fmt.Println(nanoseconds)
    // about 88 nanoseconds
}
```

## Fast linear search

```go
package main

import (
    "fmt"
    "time"
)

func fastLinearSearch(arr []int, x int) int {
    i := 0
    count := len(arr)
    arr = append(arr, x)
    for true {
        if arr[i] == x {
            if i < count {
                return i
            }
            return -1
        }
        i++
    }
    return -1
}

func main() {
    items := []int{2, 3, 5, 7, 11, 13, 17}

    fmt.Println(fastLinearSearch(items, 1))
    //print -1
    fmt.Println(fastLinearSearch(items, 7))
    //print 3
    fmt.Println(fastLinearSearch(items, 19))
    //print -1

    // *** simplified speed test ***

    items = make([]int, 10000000)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    count := 100

    start := time.Now()

    for i := 0; i < count; i++ {
        fastLinearSearch(items, 7777777)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds() / int64(count)

    fmt.Println(nanoseconds)
    // about 34 148 000 nanoseconds
}
```

## Interpolation search

```go
package main

import (
    "fmt"
    "time"
)

//works when the array is sorted
func interpolationSearch(arr []int, x int) int {
    low := 0
    high := len(arr) - 1

    for (arr[low] < x) &amp;&amp; (x < arr[high]) {
        var mid = low + ((x-arr[low])*(high-low))/(arr[high]-arr[low])

        if arr[mid] < x {
            low = mid + 1
        } else if arr[mid] > x {
            high = mid - 1
        } else {
            return mid
        }
    }

    if arr[low] == x {
        return low
    }
    if arr[high] == x {
        return high
    }
    return -1
}

func main() {
    items := []int{2, 3, 5, 7, 11, 13, 17}

    fmt.Println(interpolationSearch(items, 1))
    //print -1
    fmt.Println(interpolationSearch(items, 7))
    //print 3
    fmt.Println(interpolationSearch(items, 19))
    //print -1

    // *** simplified speed test ***

    items = make([]int, 10000000)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    count := 100

    start := time.Now()

    for i := 0; i < count; i++ {
        interpolationSearch(items, 7777777)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds() / int64(count)

    fmt.Println(nanoseconds)
    // about 41 nanoseconds
}
```

## Linear search

```go
package main

import (
    "fmt"
    "time"
)

func linearSearch(arr []int, x int) int {
    i := 0
    count := len(arr)
    for i < count {
        if arr[i] == x {
            return i
        }
        i++
    }
    return -1
}

func main() {
    items := []int{2, 3, 5, 7, 11, 13, 17}

    fmt.Println(linearSearch(items, 1))
    //print -1
    fmt.Println(linearSearch(items, 7))
    //print 3
    fmt.Println(linearSearch(items, 19))
    //print -1

    // *** simplified speed test ***

    items = make([]int, 10000000)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    count := 100

    start := time.Now()

    for i := 0; i < count; i++ {
        linearSearch(items, 7777777)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds() / int64(count)

    fmt.Println(nanoseconds)
    // about 20 910 000 nanoseconds
}
```

# Sorting Algorithms
---

## Bubble sort

```go
package main

import (
    "fmt"
    "time"
)

// Time Complexity O(n^2)
// Space Complexity O(1)

func bubbleSort(arr []int) []int {
    length := len(arr)
    items := make([]int, length)
    copy(items, arr)
    for i := 0; i < length; i++ {
        for j := i + 1; j < length; j++ {
            if items[j] < items[i] {
                var tmp = items[j]
                items[j] = items[i]
                items[i] = tmp
            }
        }
    }
    return items
}

func main() {
    items := []int{4, 1, 5, 3, 2}

    sortItems := bubbleSort(items)
    // sortItems is {1, 2, 3, 4, 5}

    // *** simplified speed test ***

    items = make([]int, 200)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    var tmp = items[5]
    items[5] = items[6]
    items[6] = tmp
    count := 10000
    start := time.Now()

    for i := 0; i < count; i++ {
        bubbleSort(items)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds()

    fmt.Println(sortItems)
    fmt.Println(nanoseconds)
    // about 683 000 000 nanoseconds
}
```

## Counting sort

```go
package main

import (
    "fmt"
    "math"
    "time"
)

// Time Complexity O(n+k)
// Space Complexity O(k)

func countingSort(arr []int) []int {
    length := len(arr)
    items := make([]int, length)
    copy(items, arr)

    var min = math.MaxInt32
    var max = math.MinInt32
    for _, x := range arr {
        if x > max {
            max = x
        }
        if x < min {
            min = x
        }
    }

    var counts = make([]int, max-min+1)

    for _, x := range arr {
        counts[x-min]++
    }

    var total = 0
    for i := min; i <= max; i++ {
        var oldCount = counts[i-min]
        counts[i-min] = total
        total += oldCount
    }

    for _, x := range arr {
        items[counts[x-min]] = x
        counts[x-min]++
    }
    return items
}

func main() {
    items := []int{4, 1, 5, 3, 2}

    sortItems := countingSort(items)
    // sortItems is {1, 2, 3, 4, 5}

    // *** simplified speed test ***

    items = make([]int, 200)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    var tmp = items[5]
    items[5] = items[6]
    items[6] = tmp
    count := 10000
    start := time.Now()

    for i := 0; i < count; i++ {
        countingSort(items)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds()

    fmt.Println(sortItems)
    fmt.Println(nanoseconds)
    // about 58 000 000 nanoseconds
}
```

## Merge sort

```go
package main

import (
    "fmt"
    "time"
)

// Time Complexity O(n log(n)))
// Space Complexity O(n)

func mergeSort(arr []int) []int {
    items := make([]int, len(arr))
    copy(items, arr)
    doMergeSort(items)
    return items
}

func doMergeSort(items []int) {
    length := len(items)
    if length == 1 {
        return
    }

    var lLeft = length / 2
    var left = make([]int, lLeft)
    copy(left, items[:lLeft])
    var lRight = length - lLeft
    var right = make([]int, lRight)
    copy(right, items[lLeft:])

    doMergeSort(left)
    doMergeSort(right)

    merge(left, right, items)
}

func merge(left []int, right []int, result []int) {
    l := 0
    r := 0
    i := 0

    for l < len(left) &amp;&amp; r < len(right) {
        if left[l] < right[r] {
            result[i] = left[l]
            l++
        } else {
            result[i] = right[r]
            r++
        }
        i++
    }
    var length = len(left) - l
    copy(result[i:i+length], left[l:])
    i = i + length
    length = len(right) - r
    copy(result[i:i+length], right[r:])
}

func main() {
    items := []int{4, 1, 5, 3, 2}

    sortItems := mergeSort(items)
    // sortItems is {1, 2, 3, 4, 5}

    // *** simplified speed test ***

    items = make([]int, 200)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    var tmp = items[5]
    items[5] = items[6]
    items[6] = tmp
    count := 10000
    start := time.Now()

    for i := 0; i < count; i++ {
        mergeSort(items)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds()

    fmt.Println(sortItems)
    fmt.Println(nanoseconds)
    // about 439 000 000 nanoseconds
}
```

## Quick sort

```go
package main

import (
    "fmt"
    "time"
)

// Time Complexity from O(n log(n)) to O(n^2)
// Space Complexity O(log(n))

func doSort(items []int, fst int, lst int) {
    if fst >= lst {
        return
    }
    i := fst
    j := lst
    x := items[(fst+lst)/2]

    for i < j {
        for items[i] < x {
            i++
        }
        for items[j] > x {
            j--
        }
        if i <= j {
            var tmp = items[i]
            items[i] = items[j]
            items[j] = tmp
            i++
            j--
        }
    }
    doSort(items, fst, j)
    doSort(items, i, lst)
}

func quicksort(arr []int) []int {
    length := len(arr)
    items := make([]int, length)
    copy(items, arr)
    doSort(items, 0, length-1)
    return items
}

func main() {
    items := []int{4, 1, 5, 3, 2}

    sortItems := quicksort(items)
    // sortItems is {1, 2, 3, 4, 5}

    // *** simplified speed test ***

    items = make([]int, 200)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    var tmp = items[5]
    items[5] = items[6]
    items[6] = tmp
    count := 10000
    start := time.Now()

    for i := 0; i < count; i++ {
        quicksort(items)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds()

    fmt.Println(sortItems)
    fmt.Println(nanoseconds)
    // about 83 000 000 nanoseconds
}
```

## Redix sort

```go
package main

import (
    "fmt"
    "math"
    "time"
)

// Time Complexity O(nk)
// Space Complexity O(n+k)

func listToBuckets(items []int, cBase int, i int) [][]int {
    var buckets = make([][]int, cBase)

    var pBase = int(math.Pow(
        float64(cBase), float64(i)))
    for _, x := range items {
        //Isolate the base-digit from the number
        var digit = (x / pBase) % cBase
        //Drop the number into the correct bucket
        buckets[digit] = append(buckets[digit], x)
    }

    return buckets
}

func bucketsToList(buckets [][]int) []int {
    result := []int{}

    for _, bucket := range buckets {
        result = append(result, bucket...)
    }

    return result
}

func radixSort(arr []int, cBase int) []int {
    maxVal := 0
    for i, value := range arr {
        if i == 0 || value > maxVal {
            maxVal = value
        }
    }

    length := len(arr)
    items := make([]int, length)
    copy(items, arr)

    i := 0
    for math.Pow(float64(cBase), float64(i)) <= float64(maxVal) {
        items = bucketsToList(listToBuckets(items, cBase, i))
        i++
    }

    return items
}

func main() {
    items := []int{4, 1, 5, 3, 2}

    sortItems := radixSort(items, 10)
    // sortItems is {1, 2, 3, 4, 5}

    // *** simplified speed test ***

    items = make([]int, 200)
    for i := 0; i < len(items); i++ {
        items[i] = i
    }
    var tmp = items[5]
    items[5] = items[6]
    items[6] = tmp
    count := 10000
    start := time.Now()

    for i := 0; i < count; i++ {
        radixSort(items, 10)
    }

    delta := time.Now().Sub(start)
    nanoseconds := delta.Nanoseconds()

    fmt.Println(sortItems)
    fmt.Println(nanoseconds)
    // about 532 200 000 nanoseconds
}
```
