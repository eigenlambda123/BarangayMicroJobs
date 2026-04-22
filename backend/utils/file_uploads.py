from pathlib import Path
from uuid import uuid4
import shutil
from typing import Optional

from fastapi import HTTPException, UploadFile, status


ALLOWED_IMAGE_TYPES = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}

ALLOWED_IMAGE_EXTENSIONS = {
    ".jpg": ".jpg",
    ".jpeg": ".jpg",
    ".png": ".png",
    ".webp": ".webp",
}


def _extension_from_signature(header: bytes) -> Optional[str]:
    # JPEG starts with FF D8 FF
    if len(header) >= 3 and header[:3] == b"\xFF\xD8\xFF":
        return ".jpg"

    # PNG starts with 89 50 4E 47 0D 0A 1A 0A
    if len(header) >= 8 and header[:8] == b"\x89PNG\r\n\x1a\n":
        return ".png"

    # WEBP: RIFF....WEBP
    if len(header) >= 12 and header[:4] == b"RIFF" and header[8:12] == b"WEBP":
        return ".webp"

    return None


def _resolve_image_extension(upload: UploadFile) -> Optional[str]:
    content_type = (upload.content_type or "").lower().strip()
    if content_type in ALLOWED_IMAGE_TYPES:
        return ALLOWED_IMAGE_TYPES[content_type]

    filename = (upload.filename or "").strip().lower()
    suffix = Path(filename).suffix
    if suffix in ALLOWED_IMAGE_EXTENSIONS:
        return ALLOWED_IMAGE_EXTENSIONS[suffix]

    current_position = upload.file.tell()
    header = upload.file.read(16)
    upload.file.seek(current_position)
    return _extension_from_signature(header)


def save_uploaded_image(upload: UploadFile, folder: str) -> str:
    ext = _resolve_image_extension(upload)
    if ext is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Use PNG, JPG, or WEBP.",
        )

    uploads_root = Path(__file__).resolve().parents[1] / "uploads"
    target_dir = uploads_root / folder
    target_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{uuid4().hex}{ext}"
    destination = target_dir / filename

    with destination.open("wb") as out_file:
        shutil.copyfileobj(upload.file, out_file)

    return f"/uploads/{folder}/{filename}"
