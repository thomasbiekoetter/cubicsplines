import pandas as pd
import matplotlib.pyplot as plt


df = pd.read_csv("interp.csv")
dg = pd.read_csv("exact.csv")
dh = pd.read_csv("smooth.csv")

fig, axs = plt.subplots(2, 1)

ax = axs[0]

ax.plot(
    df['x  '],
    df['y  '],
    label=r"$f_{\mathrm{cubic}}(x)$"
)

ax.plot(
    df['x  '],
    df['dy '],
    label=r"$\frac{df_{\mathrm{cubic}}}{dx}$"
)

ax.plot(
    df['x  '],
    df['d2y'],
    label=r"$\frac{d^2f_{\mathrm{cubic}}}{dx^2}$"
)

ax.scatter(
    dg['x0'],
    dg['y0'],
    s=8,
    label="f(x) = sin(x)"
)

ax.set_title("Without smoothing")

ax = axs[1]

ax.plot(
    dh['x  '],
    dh['y  '],
    label=r"$f_{\mathrm{cubic}}(x)$"
)

ax.plot(
    dh['x  '],
    dh['dy '],
    label=r"$\frac{df_{\mathrm{cubic}}}{dx}$"
)

ax.plot(
    dh['x  '],
    dh['d2y'],
    label=r"$\frac{d^2f_{\mathrm{cubic}}}{dx^2}$"
)

ax.scatter(
    dg['x0'],
    dg['y0'],
    s=8,
    label="f(x) = sin(x)"
)

ax.set_title("With smoothing")

plt.legend()

plt.subplots_adjust(hspace=0.4)

plt.savefig("smoothing.pdf")
