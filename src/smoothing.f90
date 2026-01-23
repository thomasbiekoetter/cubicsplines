module cubicsplines__smoothing

  use cubicsplines__config, only : wp

  implicit none

  private

  real(wp), parameter :: eps_default = 1.0e0_wp
  integer, parameter :: iterations_default = 100

  public :: add_viscosity

contains

  pure function add_viscosity(x, y, n, eps, iterations) result(ys)

    integer, intent(in) :: n
    real(wp), intent(in) :: x(n)
    real(wp), intent(in) :: y(n)
    real(wp), intent(in), optional :: eps
    integer,  intent(in), optional :: iterations
    real(wp) :: ys(n)

    real(wp) :: e
    integer :: iter
    integer :: i
    integer :: j
    real(wp) :: virtual_neighbor

    ! Assume regular grid spacing
    if (present(eps)) then
      e = eps
    else
      e = eps_default
    end if
    e = e * (x(2) - x(1)) ** 2

    if (present(iterations)) then
      iter = iterations
    else
      iter = 100
    end if

    ys = y
    do j = 1, iter
      virtual_neighbor = 2 * ys(1) - ys(2)
      ys(1) = ys(1) + e * (virtual_neighbor - 2.0e0_wp * ys(1) + ys(2))
      do i = 2, n - 1
        ys(i) = ys(i) + e * (ys(i-1) - 2.0e0_wp * ys(i) + ys(i+1))
      end do
      virtual_neighbor = 2 * ys(n) - ys(n - 1)
      ys(n) = ys(n) + e * (ys(n-1) - 2.0e0_wp * ys(n) + virtual_neighbor)
    end do

  end function add_viscosity

end module cubicsplines__smoothing
