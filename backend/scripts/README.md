# Running Dummy Job Seed Scripts

## Seed job posts directly into the database

This is the recommended script for local testing because it does not require the FastAPI server to be running.

```powershell
python scripts/seed_dummy_job_posts.py
```

Optional reset mode:

```powershell
python scripts/seed_dummy_job_posts.py --reset
```

### What it creates

- 3 dummy resident users
- 9 dummy job posts across valid Lucena barangays
- Idempotent inserts, so rerunning the script will skip existing seeded jobs

### Default credentials

- Phone numbers are printed by the script
- Password for all seeded users: `password123`

## Legacy API-driven test data script

The older `create_test_data.py` script is still available if you want to seed through the running API.

```powershell
python scripts/create_test_data.py
```

### Requirements

- FastAPI server must be running on `localhost:8000`
- `requests` library installed (`pip install requests`)
