enum GenderCharacter { Ayah, Bunda }
GenderCharacter? genderCharFromString(String gender) {
  if (gender.trim().toLowerCase() == 'ayah')
    return GenderCharacter.Ayah;
  else if (gender.trim().toLowerCase() == 'bunda')
    return GenderCharacter.Bunda;
  else
    return null;
}

enum ChildGender { Lelaki, Perempuan }

enum StatusStudyLevel { SD, SMP, SMA }
