# BarangayMicroJobs

A Flutter-based platform designed to connect local residents with micro-job opportunities within their barangay.

## Daily Workflow

To keep your local code in sync with the team:

1. **Pull latest changes:** `git pull origin main`
2. **Stage changes:** `git add .`
3. **Commit changes:** `git commit -m "Brief description of what you did"`
4. **Push to GitHub:** `git push origin feature/your-task-name`

## Backend Setup
1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```
2. **Create a virtual environment:**
   ```bash
    python -m venv venv
    ```
3. **Activate the virtual environment:**
    - On Windows:
    ```bash
    venv\Scripts\activate
    ```
    - On macOS/Linux:
    ```bash
    source venv/bin/activate
    ```
4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
5. **Run the FastAPI server:**
   ```bash
    uvicorn app.main:app --reload
    ```

