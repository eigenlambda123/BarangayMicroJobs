import requests
import json

BASE_URL = "http://localhost:8000"

# Test users data
test_users = [
    {
        "full_name": "Alice Johnson",
        "phone_number": "09111111111",
        "role": "resident",
        "password": "password123"
    },
    {
        "full_name": "Bob Smith",
        "phone_number": "09222222222",
        "role": "resident",
        "password": "password123"
    },
    {
        "full_name": "Carol Davis",
        "phone_number": "09333333333",
        "role": "resident",
        "password": "password123"
    }
]

# Job posts data
job_posts = [
    {
        "title": "House Cleaning",
        "description": "Need help cleaning my house for the weekend",
        "location": "Barangay A",
        "salary": 500.0
    },
    {
        "title": "Yard Maintenance",
        "description": "Trim hedges and clean up the yard",
        "location": "Barangay B",
        "salary": 800.0
    },
    {
        "title": "House Painting",
        "description": "Paint the exterior walls of the house",
        "location": "Barangay A",
        "salary": 1500.0
    },
    {
        "title": "Plumbing Fix",
        "description": "Fix leaking pipes in the kitchen",
        "location": "Barangay C",
        "salary": 400.0
    },
    {
        "title": "Electrical Work",
        "description": "Install new light fixtures in living room",
        "location": "Barangay B",
        "salary": 900.0
    }
]

def register_user(user_data):
    """Register a new user and return the response"""
    response = requests.post(f"{BASE_URL}/auth/register", json=user_data)
    return response.json()

def login_user(phone_number, password):
    """Login a user and return the access token"""
    data = {
        "phone_number": phone_number,
        "password": password
    }
    response = requests.post(f"{BASE_URL}/auth/login", json=data)
    if response.status_code == 200:
        return response.json()["access_token"]
    else:
        print(f"Login failed for {phone_number}: {response.text}")
        return None

def create_job_post(token, job_data):
    """Create a job post with authentication"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    response = requests.post(f"{BASE_URL}/jobs/create", json=job_data, headers=headers)
    return response.json()

def apply_for_job(token, job_id):
    """Apply for a job post"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    response = requests.post(f"{BASE_URL}/transactions/apply/{job_id}", headers=headers)
    return response.json()

def main():
    print("=" * 60)
    print("Creating Test Data for BarangayMicroJobs")
    print("=" * 60)
    
    tokens = {}
    job_ids = []
    
    # Register users
    print("\n[1] Registering test users...")
    for user in test_users:
        print(f"  - Registering {user['full_name']}...", end=" ")
        result = register_user(user)
        if "user_id" in result:
            print("✓")
            tokens[user["phone_number"]] = {
                "password": user["password"],
                "user_id": result["user_id"]
            }
        else:
            print("✗")
            print(f"    Error: {result}")
    
    # Login and get tokens
    print("\n[2] Logging in users...")
    user_tokens = {}
    for phone_number, user_info in tokens.items():
        print(f"  - Logging in {phone_number}...", end=" ")
        token = login_user(phone_number, user_info["password"])
        if token:
            print("✓")
            user_tokens[phone_number] = token
        else:
            print("✗")
    
    # Create job posts (Alice creates the first 3 jobs, Bob creates the last 2)
    print("\n[3] Creating job posts...")
    alice_token = user_tokens.get("09111111111")
    bob_token = user_tokens.get("09222222222")
    
    if alice_token:
        for i, job in enumerate(job_posts[:3]):
            print(f"  - Creating job '{job['title']}'...", end=" ")
            result = create_job_post(alice_token, job)
            if "job_id" in result:
                print("✓")
                job_ids.append(result["job_id"])
            else:
                print("✗")
                print(f"    Error: {result}")
    
    if bob_token:
        for i, job in enumerate(job_posts[3:]):
            print(f"  - Creating job '{job['title']}'...", end=" ")
            result = create_job_post(bob_token, job)
            if "job_id" in result:
                print("✓")
                job_ids.append(result["job_id"])
            else:
                print("✗")
                print(f"    Error: {result}")
    
    # Apply for some jobs (Carol applies to Bob's first job)
    print("\n[4] Applying for jobs (testing transactions)...")
    carol_token = user_tokens.get("09333333333")
    
    if carol_token and len(job_ids) > 2:
        print(f"  - Carol applying to job {job_ids[2]}...", end=" ")
        result = apply_for_job(carol_token, job_ids[2])
        if result.get("message") == "Application Submitted":
            print("✓")
        else:
            print("✗")
            print(f"    Error: {result}")
    
    # Print summary
    print("\n" + "=" * 60)
    print("Test Data Creation Summary")
    print("=" * 60)
    print(f"✓ Users created: {len(tokens)}")
    print(f"✓ Job posts created: {len(job_ids)}")
    print("\nTest Users:")
    for i, user in enumerate(test_users, 1):
        print(f"  {i}. {user['full_name']}")
        print(f"     Phone: {user['phone_number']}")
        print(f"     Password: {user['password']}")
    print("\nYou can now use these credentials to test other endpoints!")
    print("=" * 60)

if __name__ == "__main__":
    main()
