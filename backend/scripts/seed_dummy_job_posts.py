from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from sqlmodel import Session, select

from database import create_db_and_tables, engine
from models import JobPost, User
from utils.auth_utils import pwd_context


DEFAULT_PASSWORD = "password123"


SEED_USERS = [
    {
        "full_name": "Alice Johnson",
        "phone_number": "09111111111",
        "role": "resident",
        "location": "Barangay Gulang-Gulang",
        "skills": ["cleaning", "organizing", "laundry"],
    },
    {
        "full_name": "Bob Smith",
        "phone_number": "09222222222",
        "role": "resident",
        "location": "Barangay Isabang",
        "skills": ["painting", "repairs", "carpentry"],
    },
    {
        "full_name": "Carol Davis",
        "phone_number": "09333333333",
        "role": "resident",
        "location": "Barangay Dalahican",
        "skills": ["gardening", "delivery", "organizing"],
    },
]


SEED_JOBS = [
    {
        "poster_phone": "09111111111",
        "title": "House Cleaning",
        "description": "Need help cleaning a two-bedroom house before the weekend.",
        "location": "Barangay Gulang-Gulang",
        "salary": 500.0,
    },
    {
        "poster_phone": "09111111111",
        "title": "Laundry Folding and Organization",
        "description": "Fold laundry, organize cabinets, and tidy the living area.",
        "location": "Barangay Isabang",
        "salary": 450.0,
    },
    {
        "poster_phone": "09111111111",
        "title": "Weekend Grocery Errand",
        "description": "Pick up groceries from the market and deliver them home.",
        "location": "Barangay Market View",
        "salary": 350.0,
    },
    {
        "poster_phone": "09222222222",
        "title": "Yard Cleanup",
        "description": "Trim plants, sweep leaves, and collect garden waste.",
        "location": "Barangay Dalahican",
        "salary": 800.0,
    },
    {
        "poster_phone": "09222222222",
        "title": "Wall Painting Help",
        "description": "Assist in painting interior walls and moving light furniture.",
        "location": "Barangay Talao-Talao",
        "salary": 1200.0,
    },
    {
        "poster_phone": "09222222222",
        "title": "Minor Plumbing Check",
        "description": "Inspect a leaking faucet and replace simple fittings.",
        "location": "Barangay Mayao Castillo",
        "salary": 700.0,
    },
    {
        "poster_phone": "09333333333",
        "title": "Kitchen Deep Clean",
        "description": "Deep clean a kitchen area including counters and sink.",
        "location": "Barangay Bocohan",
        "salary": 650.0,
    },
    {
        "poster_phone": "09333333333",
        "title": "Delivery Assistance",
        "description": "Help deliver small parcels to nearby barangays.",
        "location": "Barangay Salinas",
        "salary": 550.0,
    },
    {
        "poster_phone": "09333333333",
        "title": "Event Setup Support",
        "description": "Set up chairs, tables, and basic decorations for a small event.",
        "location": "Barangay Market View",
        "salary": 900.0,
    },
]

SEEDED_TITLES = {job["title"] for job in SEED_JOBS}


def ensure_user(session: Session, user_data: dict) -> User:
    existing_user = session.exec(
        select(User).where(User.phone_number == user_data["phone_number"])
    ).first()
    if existing_user:
        return existing_user

    user = User(
        full_name=user_data["full_name"],
        phone_number=user_data["phone_number"],
        role=user_data["role"],
        is_verified=True,
        hashed_password=pwd_context.hash(DEFAULT_PASSWORD),
        location=user_data.get("location"),
        skills=user_data.get("skills"),
    )
    session.add(user)
    session.flush()
    return user


def ensure_job(session: Session, poster: User, job_data: dict) -> bool:
    existing_job = session.exec(
        select(JobPost).where(
            JobPost.poster_id == poster.id,
            JobPost.title == job_data["title"],
        )
    ).first()
    if existing_job:
        return False

    job = JobPost(
        poster_id=poster.id,
        title=job_data["title"],
        description=job_data["description"],
        location=job_data["location"],
        salary=job_data["salary"],
        image=None,
        applicants_count=0,
        status="open",
        last_modified=datetime.utcnow(),
        is_synced=True,
    )
    session.add(job)
    poster.jobs_posted += 1
    session.add(poster)
    return True


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Seed dummy users and job posts into the local backend database."
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete existing seeded dummy jobs before inserting fresh ones.",
    )
    args = parser.parse_args()

    create_db_and_tables()

    with Session(engine) as session:
        posters = {user_data["phone_number"]: ensure_user(session, user_data) for user_data in SEED_USERS}

        if args.reset:
            for poster in posters.values():
                jobs_to_delete = session.exec(
                    select(JobPost).where(
                        JobPost.poster_id == poster.id,
                        JobPost.title.in_(SEEDED_TITLES),
                    )
                ).all()
                for job in jobs_to_delete:
                    session.delete(job)
                    poster.jobs_posted = max(0, poster.jobs_posted - 1)
                session.add(poster)

        created_jobs = 0
        skipped_jobs = 0
        for job_data in SEED_JOBS:
            poster = posters[job_data["poster_phone"]]
            if ensure_job(session, poster, job_data):
                created_jobs += 1
            else:
                skipped_jobs += 1

        session.commit()

    print("Dummy job post seeding complete.")
    print(f"Created jobs: {created_jobs}")
    print(f"Skipped existing jobs: {skipped_jobs}")
    print("Seeded posters:")
    for user_data in SEED_USERS:
        print(f"- {user_data['full_name']} ({user_data['phone_number']})")
    print("Default password for all seeded users: password123")


if __name__ == "__main__":
    main()