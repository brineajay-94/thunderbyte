cd /var/www/pterodactyl && \
BACKUP_DIR="/root/thunderbyte-login-theme-backup-$(date +%Y%m%d-%H%M%S)" && \
mkdir -p "$BACKUP_DIR" && \
cp -a .blueprint/extensions/nebula/views/wrapper/theme/auth.blade.php "$BACKUP_DIR/" 2>/dev/null || true && \
echo "Backup created at: $BACKUP_DIR" && \
python3 - <<'PY'
from pathlib import Path

auth_path = Path(".blueprint/extensions/nebula/views/wrapper/theme/auth.blade.php")
auth_path.parent.mkdir(parents=True, exist_ok=True)

new_content = r'''@if(Auth::check() != true)
<script>
  document.querySelector("head > meta[name='theme-color'][content='#0e4688']")?.setAttribute("content", "#0f0f19");
</script>

<!-- THUNDERBYTE GLASS LOGIN THEME -->
<style id="nebula-authentication-theme">
  html, body {
    background-color: #000 !important;
    overflow-x: hidden !important;
  }

  /* Soft black overlay + Minecraft background */
  .nebula-auth-wallpaper {
    z-index: 3 !important;
    overflow: hidden !important;
    background: linear-gradient(rgba(0,0,0,.45), rgba(0,0,0,.45)),
                url("https://i.ibb.co/Lh1PrVBX/cccadc29-6937-4618-a911-93b6bacd911a.png") center/cover no-repeat !important;
    background-color: #000 !important;
    height: 100vh !important;
    width: 100vw !important;
    top: 0 !important; left: 0 !important;
    position: fixed !important;
    filter: none !important;
    scale: 1 !important;
    opacity: 1 !important;
    animation: none !important;
  }
  .nebula-auth-backdrop {
    background-color: transparent !important;
    z-index: 2 !important;
    position: fixed !important;
    left: 0; top: 0;
    width: 100vw; height: 100vh;
  }
  div.App___StyledDiv-sc-2l91w7-0.fnfeQw {
    background-color: transparent !important;
    z-index: 1 !important;
  }

  /* ========== TOP NAVIGATION ========== */
  .tb-topbar {
    position: fixed !important;
    top: 0 !important; left: 0 !important; right: 0 !important;
    z-index: 50 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 16px 24px !important;
    background: linear-gradient(to bottom, rgba(0,0,0,.55), transparent) !important;
    pointer-events: none;
  }
  .tb-topbar a { pointer-events: auto; }
  .tb-left { position: absolute !important; left: 24px !important; }
  .tb-center { display: flex !important; gap: 10px !important; }
  .tb-btn {
    display: inline-flex !important;
    align-items: center !important;
    gap: 7px !important;
    padding: 9px 16px !important;
    border-radius: 12px !important;
    background: rgba(20,20,30,.85) !important;
    border: 1px solid rgba(255,255,255,.1) !important;
    color: #e2e8f0 !important;
    font-size: 14px !important;
    font-weight: 500 !important;
    text-decoration: none !important;
    backdrop-filter: blur(8px) !important;
    transition: .2s !important;
    font-family: system-ui, sans-serif !important;
  }
  .tb-btn:hover {
    background: rgba(40,40,55,.95) !important;
    transform: translateY(-1px) !important;
  }
  .tb-btn svg { width: 16px !important; height: 16px !important; fill: currentColor !important; }
  .tb-home { color: #60a5fa !important; }
  .tb-login { color: #fff !important; }

  /* ========== LOGIN CARD ========== */
  div.LoginFormContainer__Container-sc-cyh04c-0 {
    z-index: 4 !important;
    position: fixed !important;
    width: 100% !important;
    max-width: 400px !important;
    left: 50% !important;
    top: 50% !important;
    transform: translate(-50%, -50%) !important;
    background: rgba(15,15,25,.88) !important;
    backdrop-filter: blur(14px) !important;
    -webkit-backdrop-filter: blur(14px) !important;
    border: 1px solid rgba(255,255,255,.12) !important;
    border-radius: 18px !important;
    box-shadow: 0 20px 50px rgba(0,0,0,.5) !important;
    padding: 28px 24px !important;
    color: #fff !important;
  }

  /* Force ThunderByte logo */
  .LoginFormContainer__Container-sc-cyh04c-0 .LoginFormContainer___StyledH-sc-cyh04c-1,
  .LoginFormContainer__Container-sc-cyh04c-0 h1,
  .LoginFormContainer__Container-sc-cyh04c-0 h2 {
    content: url("https://i.ibb.co/N2trFmDb/logo-1.png") !important;
    height: 52px !important;
    max-width: 100% !important;
    margin: 0 auto 20px auto !important;
    padding: 0 !important;
    display: block !important;
    border-radius: 0 !important;
    background: none !important;
  }

  /* Hide old Pterodactyl logo */
  .LoginFormContainer__Container-sc-cyh04c-0 img[src*="pterodactyl"] {
    display: none !important;
  }

  /* Title */
  .LoginFormContainer__Container-sc-cyh04c-0 h2 {
    content: none !important;
    display: block !important;
    text-align: center !important;
    font-size: 22px !important;
    font-weight: 600 !important;
    margin-bottom: 18px !important;
    color: #fff !important;
  }

  /* Inputs - clearer grey */
  .Input-sc-19rce1w-0,
  input[type=text],
  input[type=password],
  input[type=email] {
    width: 100% !important;
    padding: 12px 14px !important;
    margin-bottom: 12px !important;
    border: 1px solid rgba(255,255,255,.18) !important;
    border-radius: 10px !important;
    background: rgba(255,255,255,0.13) !important;
    color: #ffffff !important;
    font-size: 14px !important;
    outline: none !important;
    transition: .2s !important;
  }
  .Input-sc-19rce1w-0:focus,
  input:focus {
    border-color: #60a5fa !important;
    background: rgba(255,255,255,0.18) !important;
  }
  input::placeholder { color: #94a3b8 !important; }

  /* Login button */
  .Button__ButtonStyle-sc-1qu1gou-0,
  button[type=submit] {
    width: 100% !important;
    padding: 13px !important;
    border: none !important;
    border-radius: 10px !important;
    background: linear-gradient(135deg, #3b82f6, #2563eb) !important;
    color: #fff !important;
    font-size: 15px !important;
    font-weight: 600 !important;
    cursor: pointer !important;
    margin-top: 4px !important;
    transition: .2s !important;
    opacity: 1 !important;
  }
  .Button__ButtonStyle-sc-1qu1gou-0:hover,
  button[type=submit]:hover {
    transform: translateY(-1px) !important;
    box-shadow: 0 6px 20px rgba(59,130,246,.4) !important;
  }
  .Button__ButtonStyle-sc-1qu1gou-0 span { color: #fff !important; }

  /* Links */
  .LoginContainer___StyledLink-sc-qtrnpk-4,
  a[href*="password"],
  a[href*="register"] {
    color: #60a5fa !important;
  }
  .LoginContainer___StyledLink-sc-qtrnpk-4:hover {
    color: #93c5fd !important;
    text-decoration: underline !important;
  }

  /* Hide Pterodactyl branding */
  .LoginFormContainer___StyledP-sc-cyh04c-7,
  .LoginFormContainer__Container-sc-cyh04c-0 > p,
  a[href*="pterodactyl.io"] {
    display: none !important;
  }

  .LoginFormContainer___StyledDiv-sc-cyh04c-3 {
    background: none !important;
    background-color: transparent !important;
    box-shadow: none !important;
    padding: 0 !important;
  }
  div.LoginFormContainer___StyledDiv2-sc-cyh04c-4 { display: none !important; }

  div.ProgressBar___StyledDiv-sc-14ayc3f-1 {
    position: fixed !important;
    z-index: 60 !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
  }

  /* Mobile */
  @media (max-width: 620px) {
    .tb-topbar {
      flex-direction: column !important;
      gap: 12px !important;
      padding: 12px !important;
    }
    .tb-left { position: static !important; }
    .tb-center { justify-content: center !important; flex-wrap: wrap !important; }
    div.LoginFormContainer__Container-sc-cyh04c-0 {
      max-width: 92% !important;
      padding: 22px 18px !important;
    }
  }
</style>

<!-- Top Navigation -->
<div class="tb-topbar">
  <div class="tb-left">
    <a href="https://thunderbyte.bond" class="tb-btn">
      <span class="tb-home">Home</span> / <span class="tb-login">Login</span>
    </a>
  </div>
  <div class="tb-center">
    <a href="https://store.thunderbyte.bond" class="tb-btn">
      <svg viewBox="0 0 24 24"><path d="M19 6h-2c0-2.76-2.24-5-5-5S7 3.24 7 6H5c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-7-3c1.66 0 3 1.34 3 3H9c0-1.66 1.34-3 3-3zm0 10c-2.76 0-5-2.24-5-5h2c0 1.66 1.34 3 3 3s3-1.34 3-3h2c0 2.76-2.24 5-5 5z"/></svg>
      Store
    </a>
    <a href="https://status.thunderbyte.bond" class="tb-btn">
      <svg viewBox="0 0 24 24"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
      Status
    </a>
    <a href="https://discord.gg/hHKVZR3M75" class="tb-btn" target="_blank" rel="noopener">
      <svg viewBox="0 0 24 24"><path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/></svg>
      Discord
    </a>
  </div>
</div>
@endif
'''

auth_path.write_text(new_content)
print("ThunderByte glass login theme applied successfully")
PY

chown -R www-data:www-data .blueprint/extensions/nebula/views/wrapper/theme/auth.blade.php 2>/dev/null || true && \
php artisan view:clear && \
php artisan cache:clear && \
echo "" && \
echo "==============================================" && \
echo " SUCCESS – ThunderByte login theme applied" && \
echo " Backup: $BACKUP_DIR" && \
echo " Hard-refresh the login page (Ctrl+Shift+R)" && \
echo "=============================================="
