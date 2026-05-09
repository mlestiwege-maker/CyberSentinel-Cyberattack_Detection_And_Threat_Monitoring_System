import matplotlib.pyplot as plt

# Results from evaluation
labels = ["Normal Traffic", "Anomalies"]
values = [119675, 6298]

# Create chart
plt.figure(figsize=(8, 5))

bars = plt.bar(labels, values)

# Labels and title
plt.title("CyberSentinel Threat Detection Results")
plt.ylabel("Number of Records")

# Show values above bars
for bar in bars:
    yval = bar.get_height()
    plt.text(
        bar.get_x() + bar.get_width()/2,
        yval + 500,
        int(yval),
        ha='center'
    )

# Save graph
plt.savefig("threat_detection_results.png")

# Display graph
plt.show()