import sys
from pathlib import Path

# Ensure backend package root is on sys.path for tests
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
