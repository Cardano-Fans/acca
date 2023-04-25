
<div align="center">
  <img src="https://raw.githubusercontent.com/Cardano-Fans/acca/main/branding/acca.png?sanitize=true#gh-dark-mode-only" alt="Acca" height="150" />
  <img src="https://raw.githubusercontent.com/Cardano-Fans/acca/main/branding/acca.png?sanitize=true#gh-light-mode-only" alt="Acca" height="150" />
    <h2 align="center" style="border-bottom: none">Aiken's utility library.</h2>

[![Build](https://github.com/Cardano-Fans/acca/actions/workflows/tests.yml/badge.svg)](https://github.com/Cardano-Fans/acca/actions/workflows/tests.yml)
[![License](https://img.shields.io:/github/license/Cardano-Fans/acca?label=license)](https://github.com/Cardano-Fans/acca/blob/master/LICENSE)

  <hr/>
</div>


## Introduction

Acca is Aiken's utility library (https://github.com/aiken-lang/aiken).


Creators of Aiken standard library are quite opinionated what should be in Aiken's standard library (stdlib) and what should not be. They want to keep it quite minimal. This library is simply an extension / utility library that is adding many useful / repetitive functions, which somehow didn't make to std lib.

## Usage

aiken.toml
```
licences = ["Apache-2.0"]
description = "Example project"

dependencies = [
  { name = "Cardano-Fans/acca", version = "0b700c0fdd28f9f1ee4515965cd2e3fad19dd95e", source = "github" }
]
```

## Limitations
Since Aiken doesn't support libraries which both include the same std library (or any other library), this project simply clones std library. In other words Aiken's std lib is inlined in this project and there is no plan to make any changes to it.

Current std lib SHA1 version: cf69be24f594a1402d80867154a14e190888f465

## Requirements
- Aiken (https://github.com/aiken-lang/aiken)

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
Project under development, API subject to change.
