# cubicsplines

cubicsplines is a modern Fortran package for **one-dimensional cubic spline interpolation**, including evaluation of the **function value**, **first derivative**, and **second derivative**.  
It is numerically robust, thread-safe and compatible with the Fortran Package Manager (FPM).

---

## Features

- Natural cubic spline interpolation on arbitrary grids
- Evaluation of
  - spline values
  - first derivatives
  - second derivatives
- Thread-safe
- Written in modern Fortran (2008+)
- FPM-ready and easy to integrate into existing projects

---

## Installation

Add `cubicsplines` as a dependency in your `fpm.toml`:

```toml
[dependencies]
cubicsplines = { git = "https://github.com/thomas.biekoetter/cubicsplines" }
````

Then build your project with:

```sh
fpm build
```

The test program can be run with:

```sh
fpm test trigo
```

The program interpolates the sine function and its first and second derivatives. The result can be plotted with a python script contained in the folder `plots/trigo`.

---

## Basic Usage

### Importing the modules

```fortran
use cubicsplines__config, only : wp
use cubicsplines__interp, only : spline_construct
use cubicsplines__interp, only : spline_getval
```

* `wp` is the working precision kind used throughout the package. By default, it is set to double precision. To use quadruple precision, one has to define the preprocessor macro `QUAD` at compilation: `fpm build --flag="-DQUAD"
* `spline_construct` computes the spline coefficients.
* `spline_getval` evaluates the spline or its derivatives.

---

## Constructing a spline

Given a set of nodes `(x0, y0)`:

```fortran
real(wp) :: x0(n), y0(n)
real(wp) :: b(n), c(n), d(n)

call spline_construct(x0, y0, b, c, d, n)
```

This computes the cubic spline coefficients such that on each interval
([x_i, x_{i+1}])

[
S_i(x) = y_i + b_i (x-x_i) + c_i (x-x_i)^2 + d_i (x-x_i)^3
]

---

## Evaluating the spline

### Function values

```fortran
y = spline_getval(x, x0, y0, b, c, d, n)
```

### First derivative

```fortran
dy = spline_getval(x, x0, y0, b, c, d, n, derivative=1)
```

### Second derivative

```fortran
d2y = spline_getval(x, x0, y0, b, c, d, n, derivative=2)
```

The optional `derivative` argument can take the values:

| Value | Meaning           |
| ----: | ----------------- |
|     0 | spline value      |
|     1 | first derivative  |
|     2 | second derivative |

The default is `derivative = 0`.

---

## Example

```fortran
use cubicsplines__config, only : wp
use cubicsplines__interp, only : spline_construct, spline_getval

implicit none

integer, parameter :: number_nodes = 100
integer, parameter :: number_nodes_interp = 1000
real(wp) :: x0(number_nodes), y0(number_nodes)
real(wp) :: b(number_nodes), c(number_nodes), d(number_nodes)
real(wp) :: x(number_nodes_interp)
real(wp) :: y(number_nodes_interp)
real(wp) :: dy(number_nodes_interp)
real(wp) :: d2y(number_nodes_interp)
integer :: i

x0 = linspace(0.0_wp, 10.0_wp, number_nodes)
y0 = sin(x0)

call spline_construct(x0, y0, b, c, d, number_nodes)

x = linspace(0.0_wp, 10.0_wp, number_nodes_interp)

do i = 1, number_nodes_interp
  y(i)   = spline_getval(x(i), x0, y0, b, c, d, number_nodes)
  dy(i)  = spline_getval(x(i), x0, y0, b, c, d, number_nodes, derivative=1)
  d2y(i) = spline_getval(x(i), x0, y0, b, c, d, number_nodes, derivative=2)
end do
```

---

## Requirements

* Fortran compiler supporting Fortran 2008 or newer
* Fortran Package Manager (FPM)

---

## License

This project is licensed under the **MIT License**.

