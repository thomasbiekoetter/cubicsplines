program cubicsplines__test_smoothing

  use cubicsplines__config, only : wp
  use cubicsplines__interp, only : spline_construct
  use cubicsplines__interp, only : spline_getval
  use cubicsplines__smoothing, only : add_viscosity
  use csv_module, only : csv_file

  implicit none

  integer, parameter :: number_nodes = 101
  integer, parameter :: number_nodes_interp = 1001
  real(wp), parameter :: x_min = 0.5e0_wp
  real(wp), parameter :: x_max = 9.5e0_wp
  real(wp) :: x0(number_nodes)
  real(wp) :: y0(number_nodes)
  real(wp) :: y0_smooth(number_nodes)
  real(wp) :: coeffs_b(number_nodes)
  real(wp) :: coeffs_c(number_nodes)
  real(wp) :: coeffs_d(number_nodes)
  real(wp) :: coeffs_b_smooth(number_nodes)
  real(wp) :: coeffs_c_smooth(number_nodes)
  real(wp) :: coeffs_d_smooth(number_nodes)
  real(wp) :: x(number_nodes_interp)
  real(wp) :: y(number_nodes_interp)
  real(wp) :: dy(number_nodes_interp)
  real(wp) :: d2y(number_nodes_interp)
  real(wp) :: y_smooth(number_nodes_interp)
  real(wp) :: dy_smooth(number_nodes_interp)
  real(wp) :: d2y_smooth(number_nodes_interp)
  integer :: i
  real(wp) :: r

  x0 = linspace(x_min, x_max, number_nodes)

  do i = 1, number_nodes
    call random_number(r)
    y0(i) = sin(x0(i)) + 5.0e-2_wp * r
  end do

  y0_smooth = add_viscosity(  &
    x0, y0, number_nodes, eps=3.0e0_wp, iterations=300)

  x = linspace(x_min, x_max, number_nodes_interp)

  call spline_construct(x0, y0, coeffs_b, coeffs_c, coeffs_d, number_nodes)

  call spline_construct(  &
    x0, y0_smooth, coeffs_b_smooth, coeffs_c_smooth,  &
    coeffs_d_smooth, number_nodes)

  do i = 1, number_nodes_interp
    y(i) = spline_getval(  &
      x(i), x0, y0, coeffs_b, coeffs_c, coeffs_d, number_nodes)
  end do

  do i = 1, number_nodes_interp
    dy(i) = spline_getval(  &
      x(i), x0, y0, coeffs_b, coeffs_c, coeffs_d,  &
      number_nodes, derivative=1)
  end do

  do i = 1, number_nodes_interp
    d2y(i) = spline_getval(  &
      x(i), x0, y0, coeffs_b, coeffs_c, coeffs_d,  &
      number_nodes, derivative=2)
  end do

  do i = 1, number_nodes_interp
    y_smooth(i) = spline_getval(  &
      x(i), x0, y0_smooth, coeffs_b_smooth, coeffs_c_smooth,  &
      coeffs_d_smooth, number_nodes)
  end do

  do i = 1, number_nodes_interp
    dy_smooth(i) = spline_getval(  &
      x(i), x0, y0_smooth, coeffs_b_smooth, coeffs_c_smooth,  &
      coeffs_d_smooth, number_nodes, derivative=1)
  end do

  do i = 1, number_nodes_interp
    d2y_smooth(i) = spline_getval(  &
      x(i), x0, y0_smooth, coeffs_b_smooth,  &
      coeffs_c_smooth, coeffs_d_smooth, number_nodes, derivative=2)
  end do

  call write_to_csv_exact(x0, y0)

  call write_to_csv_interp(x, y, dy, d2y)

  call write_to_csv_smooth(x, y_smooth, dy_smooth, d2y_smooth)

contains

  pure function linspace(a, b, num) result(y)

    real(wp), intent(in) :: a
    real(wp), intent(in) :: b
    integer, intent(in) :: num
    real(wp), dimension(num) :: y

    integer :: i
    real(wp) :: step

    step = (b - a) / real(num - 1, wp)
    y(1) = a
    do i=2,num
      y(i) = a + (i - 1) * step
    end do

  end function linspace

  subroutine write_to_csv_exact(x0, y0)

    real(wp), intent(in) :: x0(:)
    real(wp), intent(in) :: y0(:)

    integer :: i
    type(csv_file) :: f
    logical :: status_ok

    call f%initialize(verbose=.true.)

    call f%open(  &
      "plots/smoothing/exact.csv",  &
      n_cols=4,  &
      status_ok=status_ok)

    call f%add(["x0", "y0"])

    call f%next_row()

    do i = 1, size(x0)

      call f%add([  &
        x0(i), y0(i)],  &
        real_fmt="(4es14.5)")

      call f%next_row()

    end do

    call f%close(status_ok)

  end subroutine write_to_csv_exact

  subroutine write_to_csv_interp(x, y, dy, d2y)

    real(wp), intent(in) :: x(:)
    real(wp), intent(in) :: y(:)
    real(wp), intent(in) :: dy(:)
    real(wp), intent(in) :: d2y(:)

    integer :: i
    type(csv_file) :: f
    logical :: status_ok

    call f%initialize(verbose=.true.)

    call f%open(  &
      "plots/smoothing/interp.csv",  &
      n_cols=4,  &
      status_ok=status_ok)

    call f%add(["x  ", "y  ", "dy ", "d2y"])

    call f%next_row()

    do i = 1, size(x)

      call f%add([  &
        x(i), y(i), dy(i), d2y(i)],  &
        real_fmt="(4es14.5)")

      call f%next_row()

    end do

    call f%close(status_ok)

  end subroutine write_to_csv_interp

  subroutine write_to_csv_smooth(x, y, dy, d2y)

    real(wp), intent(in) :: x(:)
    real(wp), intent(in) :: y(:)
    real(wp), intent(in) :: dy(:)
    real(wp), intent(in) :: d2y(:)

    integer :: i
    type(csv_file) :: f
    logical :: status_ok

    call f%initialize(verbose=.true.)

    call f%open(  &
      "plots/smoothing/smooth.csv",  &
      n_cols=4,  &
      status_ok=status_ok)

    call f%add(["x  ", "y  ", "dy ", "d2y"])

    call f%next_row()

    do i = 1, size(x)

      call f%add([  &
        x(i), y(i), dy(i), d2y(i)],  &
        real_fmt="(4es14.5)")

      call f%next_row()

    end do

    call f%close(status_ok)

  end subroutine write_to_csv_smooth

end program cubicsplines__test_smoothing
