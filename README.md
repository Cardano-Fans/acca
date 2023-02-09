[![License](https://img.shields.io:/github/license/Cardano-Fans/acca?label=license)](https://github.com/Cardano-Fans/acca/blob/master/LICENSE)

## Introduction

Acca is Aiken's non standard library (https://github.com/aiken-lang/aiken).


Creators of Aiken standard library are quite opinionated what is should be in there and what should not be there. They want to keep stdlib quite minimal. This library is simply an extension to standard library that is adding many useful / repetitive functions.

## Status
pre-alpha, heavy development, API may still change a lot.


## Requirements
- Aiken (https://github.com/aiken-lang/aiken)
- Aiken's std library (https://github.com/aiken-lang/stdlib)

## Examples


```gleam
use acca/list as alist

let items: List<Option<Int>> = [Some(1), None, Some(2)] 

// resolve only Some and ignore None elements
let resolved: List<Option<Int>> = alist.resolve(items)

// resolved = [Some(1), Some(2)]

// return last element
let last: Option<Int> = alist.last(resolved)
expect Some(x) = last

// x = 2
```
