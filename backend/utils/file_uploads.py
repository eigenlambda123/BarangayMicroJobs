from pathlib import Path
from uuid import uuid4
import shutil

from fastapi import HTTPException, UploadFile, status


ALLOWED_IMAGE_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


def save_uploaded_image(upload: UploadFile, folder: str) -> str:
    content_type = (upload.content_type or "").lower()
    ext = ALLOWED_IMAGE_TYPES.get(content_type)
    if ext is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Use JPG, PNG, or WEBP.",
        )

    uploads_root = Path(__file__).resolve().parents[1] / "uploads"
    target_dir = uploads_root / folder
    target_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{uuid4().hex}{ext}"
    destination = target_dir / filename

    with destination.open("wb") as out_file:
        shutil.copyfileobj(upload.file, out_file)

    return f"/uploads/{folder}/{filename}"
