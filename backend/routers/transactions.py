from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from datetime import datetime
from uuid import UUID

from database import get_session
from models import User, JobPost, JobTransaction
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions"])


