program cubicsplines__test_const

  use cubicsplines__config, only : wp
  use cubicsplines__interp, only : spline_construct
  use cubicsplines__interp, only : spline_getval
  use csv_module, only : csv_file

  implicit none

  integer, parameter :: number_nodes = 12
  integer, parameter :: number_nodes_interp = 1001
  real(wp), parameter :: x_min = 1.0e0_wp
  real(wp), parameter :: x_max = 10.0e0_wp
  real(wp) :: x0(number_nodes)
  real(wp) :: y0(number_nodes)
  real(wp) :: coeffs_b(number_nodes)
  real(wp) :: coeffs_c(number_nodes)
  real(wp) :: coeffs_d(number_nodes)
  real(wp) :: x(number_nodes_interp)
  real(wp) :: y(number_nodes_interp)
  integer :: i

  x0 = linspace(x_min, x_max, number_nodes)
  y0 = [  &
    0.0e0_wp, 0.0e0_wp, 0.0e0_wp, 1.0e0_wp,  &
    2.0e0_wp, 3.0e0_wp, 4.0e0_wp, 5.0e0_wp,  &
    6.0e0_wp, 7.0e0_wp, 7.0e0_wp, 7.0e0_wp]

  x = linspace(x_min, x_max, number_nodes_interp)

  call spline_construct(x0, y0, coeffs_b, coeffs_c, coeffs_d, number_nodes)

  do i = 1, number_nodes_interp
    y(i) = spline_getval(  &
      x(i), x0, y0, coeffs_b, coeffs_c, coeffs_d, number_nodes)
  end do

  call write_to_csv_exact(x0, y0)

  call write_to_csv_interp(x, y)

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
      "plots/const/exact.csv",  &
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

  subroutine write_to_csv_interp(x, y)

    real(wp), intent(in) :: x(:)
    real(wp), intent(in) :: y(:)

    integer :: i
    type(csv_file) :: f
    logical :: status_ok

    call f%initialize(verbose=.true.)

    call f%open(  &
      "plots/const/interp.csv",  &
      n_cols=2,  &
      status_ok=status_ok)

    call f%add(["x  ", "y  "])

    call f%next_row()

    do i = 1, size(x)

      call f%add([x(i), y(i)], real_fmt="(4es14.5)")

      call f%next_row()

    end do

    call f%close(status_ok)

  end subroutine write_to_csv_interp

end program cubicsplines__test_const
