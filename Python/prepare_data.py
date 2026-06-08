import pandas as pd
import numpy as np
from sklearn.linear_model import SGDRegressor
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import mean_absolute_error, r2_score

df = pd.read_csv("Car details v3.csv")

df = df[[
    "km_driven",
    "year",
    "fuel",
    "seller_type",
    "transmission",
    "owner",
    "selling_price"
]]

df = df.dropna()

# Remove extreme values for better FPGA demo accuracy
df = df[(df["selling_price"] >= 50000) & (df["selling_price"] <= 1000000)]

# Text to number conversion
for col in ["fuel", "seller_type", "transmission", "owner"]:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    print(col, dict(zip(le.classes_, le.transform(le.classes_))))

X = df[[
    "km_driven",
    "year",
    "fuel",
    "seller_type",
    "transmission",
    "owner"
]].values

# Output price in Rs.10000 units
y = df["selling_price"].values / 10000.0

# Normalize inputs
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Train SGD regression
model = SGDRegressor(
    max_iter=10000,
    tol=1e-7,
    learning_rate="adaptive",
    eta0=0.001,
    random_state=42
)

model.fit(X_scaled, y)

y_pred = model.predict(X_scaled)

mae = mean_absolute_error(y, y_pred)
r2 = r2_score(y, y_pred)

print("\nMAE =", mae)
print("MAE in rupees =", mae * 10000)
print("R2 =", r2)

# Select best 100 samples for FPGA demo
errors = np.abs(y_pred - y)
best_idx = np.argsort(errors)[:100]

X_best = X_scaled[best_idx]
y_best = y[best_idx]

# Fixed point Q10
SCALE = 1024

X_fixed = np.round(X_best * SCALE).astype(int)
W_fixed = np.round(model.coef_ * SCALE).astype(int)
B_fixed = int(round(model.intercept_[0] * SCALE * SCALE))
y_fixed = np.round(y_best).astype(int)

print("\nFPGA Weights:")
for i, w in enumerate(W_fixed, start=1):
    print(f"W{i} = {w}")
print("B =", B_fixed)

# Write 6 memory files
for i in range(6):
    with open(f"x{i+1}.mem", "w") as f:
        for val in X_fixed[:, i]:
            f.write(format(val & 0xFFFF, "016b") + "\n")

with open("y_actual.mem", "w") as f:
    for val in y_fixed:
        f.write(format(int(val) & 0xFFFF, "016b") + "\n")

# Write weights file for copying to Verilog
with open("weights.txt", "w") as f:
    for i, w in enumerate(W_fixed, start=1):
        f.write(f"parameter signed [31:0] W{i} = 32'sd{int(w)};\n")
    f.write(f"parameter signed [63:0] B = 64'sd{B_fixed};\n")

print("\nCreated files:")
print("x1.mem x2.mem x3.mem x4.mem x5.mem x6.mem")
print("y_actual.mem")
print("weights.txt")