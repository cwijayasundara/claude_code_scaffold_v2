# src/types/ — Shared types, enums, schemas
#
# Domain concepts should be refined Pydantic types, not raw primitives.
# Example:
#
#   from pydantic import BaseModel, EmailStr, Field
#   from typing import NewType
#
#   UserId = NewType("UserId", int)
#
#   class Email(BaseModel):
#       value: EmailStr
#
#   class UserCreate(BaseModel):
#       email: Email
#       display_name: str = Field(min_length=1, max_length=100)
#
# This makes illegal states unrepresentable — validation happens at parse
# boundaries (Repo layer), and all downstream code works with proven types.
