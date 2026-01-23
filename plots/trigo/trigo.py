import pandas as pd
import matplotlib.pyplot as plt


df = pd.read_csv("interp.csv")
dg = pd.read_csv("exact.csv")

plt.plot(
    df['x  '],
    df['y  '],
    label=r"$f_{\mathrm{cubic}}(x)$"
)

plt.plot(
    df['x  '],
    df['dy '],
    label=r"$\frac{df_{\mathrm{cubic}}}{dx}$"
)

plt.plot(
    df['x  '],
    df['d2y'],
    label=r"$\frac{d^2f_{\mathrm{cubic}}}{dx^2}$"
)

plt.plot(
    df['x  '],
    1e3 * (df['d2y'] + df['y  ']),
    label=r"$10^3 \cdot (\frac{d^2f_{\mathrm{cubic}}}{dx^2} + f_{\mathrm{cubic}}(x))$"
)

plt.scatter(
    dg['x0'],
    dg['y0'],
    s=8,
    label="f(x) = sin(x)"
)

plt.legend()

plt.savefig("trigo.pdf")
