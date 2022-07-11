enum ParentCharacter { Ayah, Bunda, Lainnya }
ParentCharacter? genderCharFromString(String gender) {
  if (gender.trim().toLowerCase() == 'ayah')
    return ParentCharacter.Ayah;
  else if (gender.trim().toLowerCase() == 'bunda')
    return ParentCharacter.Bunda;
  else if (gender.trim().toLowerCase() == 'lainnya')
    return ParentCharacter.Lainnya;
  else
    return null;
}

enum ChildGender { Pria, Wanita }

ChildGender? childGenderFromString(String gender) {
  if (gender.trim().toLowerCase() == 'Pria')
    return ChildGender.Pria;
  else if (gender.trim().toLowerCase() == 'Wanita')
    return ChildGender.Wanita;
}
enum StatusStudyLevel { SD, SMP, SMA }
