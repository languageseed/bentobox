#!/usr/bin/env python3
"""
Bentobox Installation Orchestrator
Manages the installation state, dependencies, and execution of component installers.
"""

import os
import sys
import json
import subprocess
import yaml
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
from enum import Enum

class ComponentStatus(Enum):
    NOT_INSTALLED = "not_installed"
    ALREADY_INSTALLED = "already_installed"
    INSTALLING = "installing"
    INSTALLED = "installed"
    FAILED = "failed"
    SKIPPED = "skipped"

@dataclass
class Component:
    name: str
    script: str
    category: str  # terminal, desktop, optional
    check_command: Optional[str] = None  # Command to check if installed
    prerequisites: List[str] = None  # Other components needed first
    user_selected: bool = True
    status: ComponentStatus = ComponentStatus.NOT_INSTALLED
    error_message: Optional[str] = None
    
    def __post_init__(self):
        if self.prerequisites is None:
            self.prerequisites = []

class InstallationOrchestrator:
    def __init__(self, config_path: Optional[str] = None):
        self.home = Path.home()
        self.omakub_path = Path(os.environ.get('OMAKUB_PATH', self.home / '.local/share/omakub'))
        self.state_file = self.home / '.bentobox-state.json'
        self.config_path = config_path or self.home / '.bentobox-config.yaml'
        
        self.components: Dict[str, Component] = {}
        self.state: Dict[str, any] = {}
        self.config: Dict[str, any] = {}
        
    def load_config(self):
        """Load user configuration"""
        if self.config_path.exists():
            with open(self.config_path) as f:
                self.config = yaml.safe_load(f)
            print(f"✓ Loaded config from {self.config_path}")
        else:
            print(f"ℹ No config file found, using defaults")
            self.config = {'mode': 'interactive'}
    
    def load_state(self):
        """Load previous installation state"""
        if self.state_file.exists():
            with open(self.state_file) as f:
                self.state = json.load(f)
            print(f"✓ Loaded state from {self.state_file}")
        else:
            self.state = {}
    
    def save_state(self):
        """Save current installation state"""
        state_data = {
            'components': {
                name: {
                    'status': comp.status.value,
                    'error': comp.error_message
                }
                for name, comp in self.components.items()
            }
        }
        with open(self.state_file, 'w') as f:
            json.dump(state_data, f, indent=2)
    
    def discover_components(self):
        """Scan install scripts and build component registry"""
        
        # Terminal components (always needed)
        terminal_dir = self.omakub_path / 'install/terminal'
        if terminal_dir.exists():
            for script in terminal_dir.glob('*.sh'):
                if script.name in ['terminal.sh']:  # Skip orchestrator scripts
                    continue
                
                name = script.stem.replace('app-', '').replace('-', '_')
                self.components[name] = Component(
                    name=name,
                    script=str(script),
                    category='terminal',
                    check_command=self._get_check_command(name)
                )
        
        # Desktop components (basic apps)
        desktop_dir = self.omakub_path / 'install/desktop'
        if desktop_dir.exists():
            for script in desktop_dir.glob('app-*.sh'):
                name = script.stem.replace('app-', '').replace('-', '_')
                self.components[name] = Component(
                    name=name,
                    script=str(script),
                    category='desktop',
                    check_command=self._get_check_command(name)
                )
        
        # Optional components
        optional_dir = self.omakub_path / 'install/desktop/optional'
        if optional_dir.exists():
            for script in optional_dir.glob('*.sh'):
                name = script.stem.replace('app-', '').replace('download-', '').replace('-', '_')
                self.components[name] = Component(
                    name=name,
                    script=str(script),
                    category='optional',
                    check_command=self._get_check_command(name),
                    user_selected=False  # Optional = off by default
                )
        
        print(f"✓ Discovered {len(self.components)} components")
    
    def _get_check_command(self, name: str) -> Optional[str]:
        """Get the command to check if a component is installed"""
        # Map component names to their check commands
        checks = {
            'docker': 'docker --version',
            'neovim': 'nvim --version',
            'chrome': 'google-chrome --version',
            'cursor': 'cursor --version',
            'vscode': 'code --version',
            'alacritty': 'alacritty --version',
            'btop': 'btop --version',
            'fastfetch': 'fastfetch --version',
            'github_cli': 'gh --version',
            'lazygit': 'lazygit --version',
            'zellij': 'zellij --version',
            'mise': 'mise --version',
            'nodejs': 'node --version',
            'python': 'python3 --version',
        }
        return checks.get(name)
    
    def run_preflight_check(self):
        """Check which components are already installed"""
        print("\n🔍 Running preflight check...")
        
        for name, comp in self.components.items():
            if comp.check_command:
                try:
                    result = subprocess.run(
                        comp.check_command,
                        shell=True,
                        capture_output=True,
                        timeout=5
                    )
                    if result.returncode == 0:
                        comp.status = ComponentStatus.ALREADY_INSTALLED
                        print(f"  ✓ {name} already installed")
                except Exception:
                    comp.status = ComponentStatus.NOT_INSTALLED
    
    def apply_user_preferences(self):
        """Apply user selections from config"""
        # Apply optional app selections
        selected_apps = self.config.get('desktop', {}).get('optional_apps', [])
        for name, comp in self.components.items():
            if comp.category == 'optional':
                comp.user_selected = name in selected_apps or comp.name.replace('_', '-') in selected_apps
    
    def build_install_queue(self) -> List[Component]:
        """Build ordered list of components to install"""
        queue = []
        
        for comp in self.components.values():
            # Skip if already installed
            if comp.status == ComponentStatus.ALREADY_INSTALLED:
                continue
            
            # Skip if not selected by user (for optional)
            if comp.category == 'optional' and not comp.user_selected:
                comp.status = ComponentStatus.SKIPPED
                continue
            
            queue.append(comp)
        
        # TODO: Sort by dependencies
        return queue
    
    def install_component(self, comp: Component) -> bool:
        """Install a single component"""
        print(f"\n📦 Installing {comp.name}...")
        comp.status = ComponentStatus.INSTALLING
        self.save_state()
        
        try:
            # Run the installation script
            result = subprocess.run(
                ['bash', comp.script],
                env={**os.environ, 'OMAKUB_PATH': str(self.omakub_path)},
                capture_output=False,
                timeout=300  # 5 minute timeout per component
            )
            
            if result.returncode == 0:
                comp.status = ComponentStatus.INSTALLED
                print(f"  ✅ {comp.name} installed successfully")
                self.save_state()
                return True
            else:
                comp.status = ComponentStatus.FAILED
                comp.error_message = f"Exit code: {result.returncode}"
                print(f"  ⚠️  {comp.name} failed (continuing anyway)")
                self.save_state()
                return False
                
        except subprocess.TimeoutExpired:
            comp.status = ComponentStatus.FAILED
            comp.error_message = "Installation timeout"
            print(f"  ⚠️  {comp.name} timed out (continuing anyway)")
            self.save_state()
            return False
        except Exception as e:
            comp.status = ComponentStatus.FAILED
            comp.error_message = str(e)
            print(f"  ⚠️  {comp.name} error: {e} (continuing anyway)")
            self.save_state()
            return False
    
    def run_post_install(self):
        """Run post-installation tasks (fonts, themes, etc.)"""
        # Check if we're in a desktop environment
        import os
        if not os.environ.get('DISPLAY') and not os.environ.get('WAYLAND_DISPLAY'):
            print("\n⚠️  Not in desktop session - skipping themes and fonts")
            print("   Run ~/bentobox-finish-setup.sh from desktop to complete setup")
            return
        
        print("\n" + "=" * 50)
        print("🎨 Post-Installation Setup")
        print("=" * 50)
        
        # Install fonts
        print("\n📝 Installing fonts...")
        fonts_script = self.omakub_path / 'install/desktop/fonts.sh'
        if fonts_script.exists():
            try:
                subprocess.run(['bash', str(fonts_script)], timeout=300, check=False)
                print("  ✅ Fonts installed")
            except Exception as e:
                print(f"  ⚠️  Font installation failed: {e}")
        
        # Configure fonts in GNOME
        print("\n⚙️  Configuring fonts...")
        font_config_script = self.omakub_path / 'install/desktop/configure-fonts.sh'
        if font_config_script.exists():
            try:
                subprocess.run(['bash', str(font_config_script)], timeout=60, check=False)
                print("  ✅ Fonts configured")
            except Exception as e:
                print(f"  ⚠️  Font configuration failed: {e}")
        
        # Apply GNOME theme
        print("\n🎨 Applying GNOME theme...")
        theme_script = self.omakub_path / 'install/desktop/set-gnome-theme.sh'
        if theme_script.exists():
            try:
                subprocess.run(
                    ['bash', str(theme_script)],
                    env={**os.environ, 'OMAKUB_PATH': str(self.omakub_path)},
                    timeout=60,
                    check=False
                )
                print("  ✅ Theme applied")
            except Exception as e:
                print(f"  ⚠️  Theme application failed: {e}")
        
        # Apply GNOME settings
        print("\n⚙️  Applying GNOME settings...")
        settings_script = self.omakub_path / 'install/desktop/set-gnome-settings.sh'
        if settings_script.exists():
            try:
                subprocess.run(['bash', str(settings_script)], timeout=60, check=False)
                print("  ✅ Settings applied")
            except Exception as e:
                print(f"  ⚠️  Settings application failed: {e}")
        
        print("\n✨ Post-installation setup complete!")
    
    def run(self):
        """Main orchestration flow"""
        print("🚀 Bentobox Installation Orchestrator")
        print("=" * 50)
        
        # 1. Load config and state
        self.load_config()
        self.load_state()
        
        # 2. Discover all available components
        self.discover_components()
        
        # 3. Run preflight to detect what's already installed
        self.run_preflight_check()
        
        # 4. Apply user preferences
        self.apply_user_preferences()
        
        # 5. Build installation queue
        queue = self.build_install_queue()
        
        if not queue:
            print("\n✅ All components already installed!")
            # Still run post-install for themes/fonts
            self.run_post_install()
            return
        
        print(f"\n📋 Installation plan: {len(queue)} components")
        for comp in queue:
            print(f"   • {comp.name} ({comp.category})")
        
        # 6. Install each component
        print("\n" + "=" * 50)
        print("Starting installation...")
        print("=" * 50)
        
        success_count = 0
        failed_count = 0
        
        for comp in queue:
            if self.install_component(comp):
                success_count += 1
            else:
                failed_count += 1
        
        # 7. Run post-installation (fonts, themes)
        self.run_post_install()
        
        # 8. Report results
        print("\n" + "=" * 50)
        print("📊 Installation Summary")
        print("=" * 50)
        print(f"  ✅ Successful: {success_count}")
        print(f"  ⚠️  Failed: {failed_count}")
        print(f"  ⏭️  Skipped: {sum(1 for c in self.components.values() if c.status == ComponentStatus.SKIPPED)}")
        print(f"  📦 Already installed: {sum(1 for c in self.components.values() if c.status == ComponentStatus.ALREADY_INSTALLED)}")
        
        if failed_count > 0:
            print("\n⚠️  Failed components:")
            for comp in self.components.values():
                if comp.status == ComponentStatus.FAILED:
                    print(f"   • {comp.name}: {comp.error_message}")
        
        print(f"\n💾 State saved to: {self.state_file}")
        print("\n✅ Installation complete!")

def main():
    config_path = sys.argv[1] if len(sys.argv) > 1 else None
    orchestrator = InstallationOrchestrator(config_path)
    orchestrator.run()

if __name__ == '__main__':
    main()

