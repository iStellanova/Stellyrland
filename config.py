# ==========================================
# SHARED CONSTANTS
# ==========================================
import os

USER = os.environ.get("SUDO_USER") or os.environ.get("USER") or "stellanova"
HOME = f"/root" if USER == "root" else f"/home/{USER}"
REGION = "United States"
