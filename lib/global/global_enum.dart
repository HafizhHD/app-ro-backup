enum GenderCharacter { Ayah, Bunda, Lainnya }
GenderCharacter? genderCharFromString(String gender) {
  if (gender.trim().toLowerCase() == 'ayah')
    return GenderCharacter.Ayah;
  else if (gender.trim().toLowerCase() == 'bunda')
    return GenderCharacter.Bunda;
  else if (gender.trim().toLowerCase() == 'lainnya')
    return GenderCharacter.Lainnya;
  else
    return null;
}

enum ChildGender { Lelaki, Perempuan }

enum StatusStudyLevel { SD, SMP, SMA }
