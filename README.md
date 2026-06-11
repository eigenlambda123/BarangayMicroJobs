# BarangayMicroJobs

<p align="center">
  <img src="frontend/logo/logo.png" alt="BarangayMicroJobs Logo" width="180"/>
</p>

BarangayMicroJobs is a community platform that connects local residents with nearby micro-job opportunities.

## What this project includes

- **Mobile app**: Flutter app in `/mock_frontend/app`
- **Backend API**: FastAPI server in `/backend`
- **Docs/diagrams**: Project diagrams in `/UMLDiagrams`

## Quick Setup (Recommended)

### 1) Prerequisites

Install these first:

- Flutter SDK (3.x)
- Python 3.10+
- Git

### 2) Start the backend

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Backend runs at `http://127.0.0.1:8000`.
API docs: `http://127.0.0.1:8000/docs`

### 3) Start the Flutter app

Open a new terminal:

```bash
cd mock_frontend/app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Useful Commands

### Frontend (Flutter)

```bash
cd mock_frontend/app
flutter analyze
flutter test
flutter build apk --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### Backend (FastAPI)

```bash
cd backend
source venv/bin/activate   # Windows: venv\Scripts\activate
uvicorn app.main:app --reload
```

## Common API Endpoints

- `POST /auth/register` - Register user
- `POST /auth/login` - Login
- `GET /jobs/` - List jobs
- `POST /jobs/create` - Create job
- `POST /transactions/apply/{job_id}` - Apply for job

See full interactive docs at `http://127.0.0.1:8000/docs`.

## Project Structure

```text
BarangayMicroJobs/
├── backend/                # FastAPI backend
├── mock_frontend/app/      # Flutter mobile app
├── frontend/logo/          # Branding assets
└── UMLDiagrams/            # Design and architecture diagrams
```

## Troubleshooting

- If app cannot connect to backend, check the `API_BASE_URL` value.
- On Android emulator, you may need `10.0.2.2` instead of `127.0.0.1`.
- If dependencies fail, re-run `flutter pub get` or `pip install -r requirements.txt`.

## Contributors

- Alegre, Raphael Hugo I.
- Altamira, Lester Adriane D.
- Cadeliña, Iggy Michael V.
- Villa, RM A.
- Villapando, Gabriel Salvadore E.

Manuel S. Enverga University Foundation - February 2026
