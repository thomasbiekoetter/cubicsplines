module cubicsplines__interp

  use cubicsplines__config, only : wp
  use error_handling, only: error_t, fail

  implicit none

  private

  public :: spline_construct
  public :: spline_getval

contains

  pure subroutine spline_construct(x, y, b, c, d, n)
  !======================================================================
  ! function ispline evaluates the cubic spline interpolation at point z
  ! ispline = y(i)+b(i)*(u-x(i))+c(i)*(u-x(i))**2+d(i)*(u-x(i))**3
  ! where  x(i) <= u <= x(i+1)
  !----------------------------------------------------------------------
  ! input..
  ! u       = the abscissa at which the spline is to be evaluated
  ! x, y    = the arrays of given data points
  ! b, c, d = arrays of spline coefficients computed by spline
  ! n       = the number of data points
  ! output:
  ! ispline = interpolated value at point u
  !
  ! T. Biekoetter modifications:
  !     - changed real kind
  !     - put in module
  !     - pure procedures, thread save
  !=======================================================================

    integer, intent(in) :: n
    real(wp), intent(in) :: x(n)
    real(wp), intent(in) :: y(n)
    real(wp), intent(out) :: b(n)
    real(wp), intent(out) :: c(n)
    real(wp), intent(out) :: d(n)

    integer :: i
    integer :: j
    integer :: gap
    real(wp) :: h
    class(error_t), allocatable :: error

    if (n < 2) then
      error = fail('construct_spline(): argument n must be >= 2.')
      error stop error%to_chars()
    end if

    gap = n - 1

    if ( n < 3 ) then
      ! linear interpolation
      b(1) = (y(2)-y(1))/(x(2)-x(1))
      c(1) = 0.0e0_wp
      d(1) = 0.0e0_wp
      b(2) = b(1)
      c(2) = 0.0e0_wp
      d(2) = 0.0e0_wp
      return
    end if

    ! step 1: preparation
    d(1) = x(2) - x(1)
    c(2) = (y(2) - y(1)) / d(1)
    do i = 2, gap
      d(i) = x(i+1) - x(i)
      b(i) = 2.0e0_wp * (d(i-1) + d(i))
      c(i+1) = (y(i+1) - y(i)) / d(i)
      c(i) = c(i+1) - c(i)
    end do

    ! step 2: end conditions
    b(1) = -d(1)
    b(n) = -d(n-1)
    c(1) = 0.0e0_wp
    c(n) = 0.0e0_wp
    if (n /= 3) then
      c(1) = c(3) / (x(4)-x(2)) - c(2) / (x(3)-x(1))
      c(n) = c(n-1) / (x(n) - x(n-2)) - c(n-2) / (x(n-1) - x(n-3))
      c(1) = c(1) * d(1)**2 / (x(4) - x(1))
      c(n) = -c(n) * d(n-1)**2 / (x(n) - x(n-3))
    end if

    ! step 3: forward elimination
    do i = 2, n
      h = d(i-1) / b(i-1)
      b(i) = b(i) - h * d(i-1)
      c(i) = c(i) - h * c(i-1)
    end do

    ! step 4: back substitution
    c(n) = c(n) / b(n)
    do j = 1, gap
      i = n - j
      c(i) = (c(i) - d(i) * c(i+1)) / b(i)
    end do

    ! step 5: compute spline coefficients
    b(n) = (y(n) - y(gap)) / d(gap) + d(gap) * (c(gap) + 2.0e0_wp * c(n))
    do i = 1, gap
      b(i) = (y(i+1) - y(i)) / d(i) - d(i) * (c(i+1) + 2.0e0_wp * c(i))
      d(i) = (c(i+1) - c(i)) / d(i)
      c(i) = 3.0e0_wp *c(i)
    end do

    c(n) = 3.0e0_wp * c(n)
    d(n) = d(n-1)

  end subroutine spline_construct

  pure function spline_getval(u, x, y, b, c, d, n, derivative) result(ispline)
  !======================================================================
  ! function ispline evaluates the cubic spline interpolation at point z
  ! ispline = y(i)+b(i)*(u-x(i))+c(i)*(u-x(i))**2+d(i)*(u-x(i))**3
  ! where  x(i) <= u <= x(i+1)
  !----------------------------------------------------------------------
  ! input..
  ! u       = the abscissa at which the spline is to be evaluated
  ! x, y    = the arrays of given data points
  ! b, c, d = arrays of spline coefficients computed by spline
  ! n       = the number of data points
  ! output:
  ! ispline = interpolated value at point u
  !
  ! T. Biekoetter modifications:
  !     - changed real kind
  !     - put in module
  !     - pure procedures, thread save
  !     - added first and second derivative
  !
  !=======================================================================

    integer, intent(in) :: n
    real(wp), intent(in) :: u
    real(wp), intent(in) :: x(n)
    real(wp), intent(in) :: y(n)
    real(wp), intent(in) :: b(n)
    real(wp), intent(in) :: c(n)
    real(wp), intent(in) :: d(n)
    integer, intent(in), optional :: derivative
    real(wp) :: ispline

    integer :: i
    integer :: j
    integer :: k
    real(wp) :: uu
    real(wp) :: dx
    integer :: deriv
    class(error_t), allocatable :: error

    if (present(derivative)) then
      deriv = derivative
    else
      deriv = 0
    end if

    uu = u
    ! if u is ouside the x() interval take a bouudary value (left or right)
    if(uu <= x(1)) then
      if (deriv == 0) then
        ispline = y(1)
        return
      else
        uu = x(1)
      end if
    end if
    if(uu >= x(n)) then
      if (deriv == 0) then
        ispline = y(n)
        return
      else
        uu = x(n)
      end if
    end if

    ! binary search for i such that x(i) <= u <= x(i+1)
    i = 1
    j = n + 1
    do while (j > i + 1)
      k = (i + j) / 2
      if(uu < x(k)) then
        j = k
      else
        i = k
      end if
    end do

    ! evaluate spline interpolation
    dx = uu - x(i)

    if (deriv == 0) then
      ispline = y(i) + dx * (b(i) + dx * (c(i) + dx * d(i)))
    else if (deriv == 1) then
      ispline = b(i) + 2.0e0_wp * c(i) * dx + 3.0e0_wp * d(i) * dx ** 2
    else if (deriv == 2) then
      ispline = 2.0e0_wp * c(i) + 6.0e0_wp * d(i) * dx
    else
      error = fail('spline_getval(): argument derivative must be 0, 1 or 2.')
      error stop error%to_chars()
    end if

  end function spline_getval

end module cubicsplines__interp
