(function () {
  const savedName = localStorage.getItem('spotify_profile_name');
  const savedPhoto = localStorage.getItem('spotify_profile_photo');
  function applyProfile() {
    const name = savedName || 'sleepffz';
    document.querySelectorAll('#profile-name,#drawer-name').forEach((el) => { el.textContent = name; });
    if (savedPhoto) {
      document.querySelectorAll('.avatar,.profile-avatar').forEach((el) => { el.style.backgroundImage = `url(${savedPhoto})`; });
    }
  }
  window.editProfile = function () {
    const current = localStorage.getItem('spotify_profile_name') || 'sleepffz';
    const name = prompt('Nome do perfil', current);
    if (name && name.trim()) {
      localStorage.setItem('spotify_profile_name', name.trim());
      applyProfile();
    }
    if (confirm('Trocar foto de perfil?')) document.getElementById('photo').click();
  };
  window.changePhoto = function (event) {
    const file = event.target.files && event.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function () {
      localStorage.setItem('spotify_profile_photo', reader.result);
      applyProfile();
    };
    reader.readAsDataURL(file);
  };
  window.addEventListener('load', applyProfile);
})();
