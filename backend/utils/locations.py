"""
Location constants for Lucena City, Quezon
"""

LUCENA_BARANGAYS = [
    "Aplaya",
    "Ayos",
    "Bago Bantay",
    "Balagtasan",
    "Balanoy",
    "Bangkerohan",
    "Batuhan",
    "Binakayan",
    "Bubukal",
    "Cabayugan",
    "Calaruan",
    "Canumay",
    "Dao",
    "Dayap",
    "Demecal",
    "Halaya",
    "Ibabang Dupax",
    "Ibabao",
    "Kanluran",
    "Kinabuhasan",
    "Laya",
    "Longos",
    "Makabayan",
    "Mataas na Paho",
    "Maunlad",
    "Pagsangahan",
    "Poblacion",
    "Pulo",
    "San Isidro",
    "Santo Domingo",
]

def get_location_choices() -> list[str]:
    """Returns list of valid locations in Lucena City"""
    return LUCENA_BARANGAYS

def is_valid_location(location: str) -> bool:
    """Validates if the given location is a valid barangay in Lucena City"""
    return location in LUCENA_BARANGAYS
