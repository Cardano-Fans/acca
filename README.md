[![License](https://img.shields.io:/github/license/Cardano-Fans/acca?label=license)](https://github.com/Cardano-Fans/acca/blob/master/LICENSE)

## Introduction

Acca is Aiken's non standard library (https://github.com/aiken-lang/aiken).


Creators of Aiken standard library are quite opinionated what is should be in there and what should not be there. They want to keep stdlib quite minimal. This library is simply an extension to standard library that is adding many useful / repetitive functions.

## Adding

aiken.toml
```
licences = ["Apache-2.0"]
description = "Example project"

dependencies = [
  { name = "Cardano-Fans/acca", version = "80ba91fa1b21953b9044c595d3c382665d976043", source = "github" }
]
```

## Requirements
- Aiken (https://github.com/aiken-lang/aiken)
- Aiken's std library (https://github.com/aiken-lang/stdlib)

## Examples

```gleam
use acca/list as alist
use acca/math as amath

let items: List<Option<Int>> = [Some(1), None, Some(2)] 

// resolve only Some and ignore None elements
let resolved: List<Option<Int>> = alist.resolve(items)

// resolved = [Some(1), Some(2)]

let min: Option<Int> = amath.min([1, 2, 3])
expect Some(x) = min

// x = 1

let max: Option<Int> = amath.max([1, 2, 3])
expect Some(x) = max

// x = 3

let indexOf: Option<Int> = alist.index_of([1, 2, 3], 3)
expect Some(x) = indexOf

// x = 2

let sum: Option<Int> = amath.sum([1, 2, 3])
expect Some(x) = sum

// x = 6

let product: Option<Int> = amath.product([1, 2, 3, 4])
expect Some(x) = product

// x = 24

// and many more functions...
```

## Why acca?
Acca (Acca sellowiana) is brazilian guava fruit. The name is not accidental, this library is a tribute to well known Google's java library called guava.

## Status
Project under heavy development, API subject to change.
