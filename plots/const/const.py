import pandas as pd
import matplotlib.pyplot as plt


df = pd.read_csv("interp.csv")
dg = pd.read_csv("exact.csv")

plt.plot(
    df['x  '],
    df['y  '],
    label=r"$f_{\mathrm{cubic}}(x)$"
)

plt.scatter(
    dg['x0'],
    dg['y0'],
    s=8,
    label="f(x) = 2"
)

plt.legend()

plt.savefig("const.pdf")
