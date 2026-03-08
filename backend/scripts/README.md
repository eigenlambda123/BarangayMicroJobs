# Running Test Data Script

## Quick Start

```powershell
cd c:\Users\PC\Desktop\BarangayMicroJobs\backend
python create_test_data.py
```

## Requirements

- FastAPI server must be running on `localhost:8000`
- `requests` library installed (`pip install requests`)

## What it creates

- 3 test users with different roles
- 5 dummy job posts
- 1 example transaction (Carol accepts a job)

All credentials will be displayed after the script runs.
