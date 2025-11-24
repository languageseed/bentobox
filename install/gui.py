#!/usr/bin/env python3
"""
Bentobox GUI Installer
Simple desktop interface for managing Bentobox installation
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Vte', '2.91')
from gi.repository import Gtk, GLib, Vte, Pango

import os
import sys
import json
import yaml
import subprocess
import threading
from pathlib import Path
from typing import Dict, List, Optional

class BentoboxGUI:
    def __init__(self):
        self.home = Path.home()
        self.omakub_path = Path(os.environ.get('OMAKUB_PATH', self.home / '.local/share/omakub'))
        self.config_path = self.home / '.bentobox-config.yaml'
        self.state_file = self.home / '.bentobox-state.json'
        
        self.config = self.load_config()
        self.state = self.load_state()
        self.selected_apps = set()
        self.selected_languages = set()
        self.selected_containers = set()
        self.selected_theme = 'tokyo-night'
        
        self.build_ui()
    
    def load_config(self) -> dict:
        """Load existing config or return defaults"""
        if self.config_path.exists():
            with open(self.config_path) as f:
                return yaml.safe_load(f)
        return {
            'mode': 'interactive',
            'desktop': {'optional_apps': []},
            'languages': [],
            'containers': []
        }
    
    def load_state(self) -> dict:
        """Load installation state"""
        if self.state_file.exists():
            with open(self.state_file) as f:
                return json.load(f)
        return {}
    
    def save_config(self):
        """Save config to file"""
        # Get selected theme
        selected_theme = 'tokyo-night'  # default
        if hasattr(self, 'theme_radios'):
            for theme, radio in self.theme_radios.items():
                if radio.get_active():
                    selected_theme = theme
                    break
        
        config = {
            'mode': 'unattended',
            'desktop': {
                'optional_apps': list(self.selected_apps),
                'theme': selected_theme,
                'install_fonts': self.install_fonts_cb.get_active() if hasattr(self, 'install_fonts_cb') else True,
                'install_ia_fonts': self.install_ia_fonts_cb.get_active() if hasattr(self, 'install_ia_fonts_cb') else True,
                'set_wallpaper': self.set_wallpaper_cb.get_active() if hasattr(self, 'set_wallpaper_cb') else True,
                'apply_gnome_settings': self.gnome_settings_cb.get_active() if hasattr(self, 'gnome_settings_cb') else True,
                'apply_hotkeys': self.gnome_hotkeys_cb.get_active() if hasattr(self, 'gnome_hotkeys_cb') else True,
                'install_extensions': self.gnome_extensions_cb.get_active() if hasattr(self, 'gnome_extensions_cb') else False,
            },
            'languages': list(self.selected_languages),
            'containers': list(self.selected_containers),
            'settings': {
                'auto_reboot': False,
                'verbose': True,
                'skip_preflight': False,
                'stop_on_warnings': False,
                'auto_upgrade': False
            }
        }
        
        with open(self.config_path, 'w') as f:
            yaml.dump(config, f, default_flow_style=False)
    
    def build_ui(self):
        """Build the GTK interface"""
        self.window = Gtk.Window(title="Bentobox Installer")
        self.window.set_default_size(900, 700)
        self.window.set_border_width(10)
        self.window.connect("destroy", Gtk.main_quit)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.window.add(main_box)
        
        # Header
        header = Gtk.Label()
        header.set_markup("<big><b>🚀 Bentobox Installation Manager</b></big>")
        header.set_margin_bottom(10)
        main_box.pack_start(header, False, False, 0)
        
        # Notebook for tabs
        notebook = Gtk.Notebook()
        main_box.pack_start(notebook, True, True, 0)
        
        # Tab 1: Component Selection
        selection_box = self.build_selection_tab()
        notebook.append_page(selection_box, Gtk.Label(label="📦 Components"))
        
        # Tab 2: Desktop Customization
        desktop_box = self.build_desktop_tab()
        notebook.append_page(desktop_box, Gtk.Label(label="🎨 Desktop"))
        
        # Tab 3: Installation
        install_box = self.build_install_tab()
        notebook.append_page(install_box, Gtk.Label(label="▶️  Install"))
        
        # Tab 4: Status
        status_box = self.build_status_tab()
        notebook.append_page(status_box, Gtk.Label(label="📊 Status"))
        
        # Bottom button bar
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        button_box.set_margin_top(10)
        main_box.pack_start(button_box, False, False, 0)
        
        # Save config button
        save_btn = Gtk.Button(label="💾 Save Configuration")
        save_btn.connect("clicked", self.on_save_config)
        button_box.pack_start(save_btn, False, False, 0)
        
        # Apply themes button
        themes_btn = Gtk.Button(label="🎨 Apply Themes & Fonts")
        themes_btn.connect("clicked", self.on_apply_themes)
        button_box.pack_start(themes_btn, False, False, 0)
        
        # Spacer
        button_box.pack_start(Gtk.Label(), True, True, 0)
        
        # Install button
        self.install_btn = Gtk.Button(label="🚀 Start Installation")
        self.install_btn.get_style_context().add_class('suggested-action')
        self.install_btn.connect("clicked", self.on_start_install)
        button_box.pack_end(self.install_btn, False, False, 0)
        
        self.window.show_all()
    
    def build_selection_tab(self) -> Gtk.Box:
        """Build component selection tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        # Content box
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        content.set_margin_start(10)
        content.set_margin_end(10)
        content.set_margin_top(10)
        scrolled.add(content)
        
        # Optional Desktop Apps
        apps_label = Gtk.Label()
        apps_label.set_markup("<b>Desktop Applications</b>")
        apps_label.set_halign(Gtk.Align.START)
        content.pack_start(apps_label, False, False, 0)
        
        apps = [
            ("1password", "1Password - Password Manager"),
            ("cursor", "Cursor - AI Code Editor"),
            ("tailscale", "Tailscale - Mesh VPN"),
            ("brave", "Brave - Privacy Browser"),
            ("chrome", "Google Chrome"),
            ("gimp", "GIMP - Image Editor"),
            ("obs-studio", "OBS Studio - Screen Recorder"),
            ("rubymine", "RubyMine - Ruby IDE"),
            ("sublime-text", "Sublime Text - Text Editor"),
            ("winboat", "WinBoat - Run Windows Apps"),
        ]
        
        apps_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        apps_box.set_margin_start(20)
        content.pack_start(apps_box, False, False, 0)
        
        for app_id, app_name in apps:
            cb = Gtk.CheckButton(label=app_name)
            cb.set_active(app_id in self.config.get('desktop', {}).get('optional_apps', []))
            cb.connect("toggled", self.on_app_toggled, app_id)
            apps_box.pack_start(cb, False, False, 0)
        
        # Programming Languages
        lang_label = Gtk.Label()
        lang_label.set_markup("<b>Programming Languages</b>")
        lang_label.set_halign(Gtk.Align.START)
        lang_label.set_margin_top(10)
        content.pack_start(lang_label, False, False, 0)
        
        languages = [
            ("Node.js", "Node.js - JavaScript Runtime"),
            ("Python", "Python - Programming Language"),
            ("Ruby on Rails", "Ruby on Rails"),
            ("Go", "Go - Programming Language"),
            ("PHP", "PHP - Programming Language"),
            ("Elixir", "Elixir - Functional Language"),
            ("Rust", "Rust - Systems Language"),
            ("Java", "Java - Programming Language"),
        ]
        
        lang_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        lang_box.set_margin_start(20)
        content.pack_start(lang_box, False, False, 0)
        
        for lang_id, lang_name in languages:
            cb = Gtk.CheckButton(label=lang_name)
            cb.set_active(lang_id in self.config.get('languages', []))
            cb.connect("toggled", self.on_lang_toggled, lang_id)
            lang_box.pack_start(cb, False, False, 0)
        
        # Docker Containers
        container_label = Gtk.Label()
        container_label.set_markup("<b>Docker Containers</b>")
        container_label.set_halign(Gtk.Align.START)
        container_label.set_margin_top(10)
        content.pack_start(container_label, False, False, 0)
        
        containers = [
            ("Portainer", "Portainer - Docker Management UI"),
            ("OpenWebUI", "OpenWebUI - AI Chat Interface"),
            ("Ollama", "Ollama - Local LLM Server"),
        ]
        
        container_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        container_box.set_margin_start(20)
        content.pack_start(container_box, False, False, 0)
        
        for container_id, container_name in containers:
            cb = Gtk.CheckButton(label=container_name)
            cb.set_active(container_id in self.config.get('containers', []))
            cb.connect("toggled", self.on_container_toggled, container_id)
            container_box.pack_start(cb, False, False, 0)
        
        return box
    
    def build_desktop_tab(self) -> Gtk.Box:
        """Build desktop customization tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        # Content box
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        content.set_margin_start(10)
        content.set_margin_end(10)
        content.set_margin_top(10)
        scrolled.add(content)
        
        # === THEME SELECTION ===
        theme_label = Gtk.Label()
        theme_label.set_markup("<b>🎨 Theme Selection</b>")
        theme_label.set_halign(Gtk.Align.START)
        content.pack_start(theme_label, False, False, 0)
        
        # Get available themes
        themes_dir = self.omakub_path / 'themes'
        available_themes = []
        if themes_dir.exists():
            available_themes = [d.name for d in themes_dir.iterdir() if d.is_dir() and not d.name.startswith('.')]
        
        if not available_themes:
            available_themes = ['tokyo-night', 'catppuccin', 'everforest', 'gruvbox', 'nord', 'rose-pine']
        
        theme_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        theme_box.set_margin_start(20)
        content.pack_start(theme_box, False, False, 0)
        
        # Radio buttons for themes
        self.theme_radios = {}
        first_radio = None
        current_theme = self.config.get('desktop', {}).get('theme', 'tokyo-night')
        
        for theme in sorted(available_themes):
            theme_display = theme.replace('-', ' ').title()
            if first_radio is None:
                radio = Gtk.RadioButton(label=theme_display)
                first_radio = radio
            else:
                radio = Gtk.RadioButton.new_from_widget(first_radio)
                radio.set_label(theme_display)
            
            if theme == current_theme:
                radio.set_active(True)
            
            radio.connect("toggled", self.on_theme_selected, theme)
            self.theme_radios[theme] = radio
            theme_box.pack_start(radio, False, False, 0)
        
        # === FONTS ===
        fonts_label = Gtk.Label()
        fonts_label.set_markup("<b>📝 Fonts</b>")
        fonts_label.set_halign(Gtk.Align.START)
        fonts_label.set_margin_top(10)
        content.pack_start(fonts_label, False, False, 0)
        
        fonts_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        fonts_box.set_margin_start(20)
        content.pack_start(fonts_box, False, False, 0)
        
        self.install_fonts_cb = Gtk.CheckButton(label="Install Cascadia Mono (Nerd Font)")
        self.install_fonts_cb.set_active(self.config.get('desktop', {}).get('install_fonts', True))
        fonts_box.pack_start(self.install_fonts_cb, False, False, 0)
        
        self.install_ia_fonts_cb = Gtk.CheckButton(label="Install iA Writer Mono")
        self.install_ia_fonts_cb.set_active(self.config.get('desktop', {}).get('install_ia_fonts', True))
        fonts_box.pack_start(self.install_ia_fonts_cb, False, False, 0)
        
        # === WALLPAPER ===
        wallpaper_label = Gtk.Label()
        wallpaper_label.set_markup("<b>🖼️  Wallpaper</b>")
        wallpaper_label.set_halign(Gtk.Align.START)
        wallpaper_label.set_margin_top(10)
        content.pack_start(wallpaper_label, False, False, 0)
        
        wallpaper_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        wallpaper_box.set_margin_start(20)
        content.pack_start(wallpaper_box, False, False, 0)
        
        self.set_wallpaper_cb = Gtk.CheckButton(label="Set custom wallpaper")
        self.set_wallpaper_cb.set_active(self.config.get('desktop', {}).get('set_wallpaper', True))
        wallpaper_box.pack_start(self.set_wallpaper_cb, False, False, 0)
        
        # Wallpaper preview (if available)
        wallpaper_dir = self.omakub_path / 'wallpaper'
        if wallpaper_dir.exists():
            wallpapers = list(wallpaper_dir.glob('*.jpg')) + list(wallpaper_dir.glob('*.png'))
            if wallpapers:
                preview_label = Gtk.Label(label=f"Available: {len(wallpapers)} wallpaper(s)")
                preview_label.set_halign(Gtk.Align.START)
                preview_label.set_margin_start(20)
                wallpaper_box.pack_start(preview_label, False, False, 0)
        
        # === GNOME SETTINGS ===
        gnome_label = Gtk.Label()
        gnome_label.set_markup("<b>⚙️  GNOME Configuration</b>")
        gnome_label.set_halign(Gtk.Align.START)
        gnome_label.set_margin_top(10)
        content.pack_start(gnome_label, False, False, 0)
        
        gnome_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        gnome_box.set_margin_start(20)
        content.pack_start(gnome_box, False, False, 0)
        
        self.gnome_settings_cb = Gtk.CheckButton(label="Apply GNOME settings (dock, etc.)")
        self.gnome_settings_cb.set_active(self.config.get('desktop', {}).get('apply_gnome_settings', True))
        gnome_box.pack_start(self.gnome_settings_cb, False, False, 0)
        
        self.gnome_hotkeys_cb = Gtk.CheckButton(label="Configure keyboard shortcuts")
        self.gnome_hotkeys_cb.set_active(self.config.get('desktop', {}).get('apply_hotkeys', True))
        gnome_box.pack_start(self.gnome_hotkeys_cb, False, False, 0)
        
        self.gnome_extensions_cb = Gtk.CheckButton(label="Install GNOME extensions (requires browser approval)")
        self.gnome_extensions_cb.set_active(self.config.get('desktop', {}).get('install_extensions', False))
        gnome_box.pack_start(self.gnome_extensions_cb, False, False, 0)
        
        # === QUICK ACTIONS ===
        actions_label = Gtk.Label()
        actions_label.set_markup("<b>🚀 Quick Actions</b>")
        actions_label.set_halign(Gtk.Align.START)
        actions_label.set_margin_top(10)
        content.pack_start(actions_label, False, False, 0)
        
        actions_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        actions_box.set_margin_start(20)
        actions_box.set_margin_top(5)
        content.pack_start(actions_box, False, False, 0)
        
        apply_now_btn = Gtk.Button(label="🎨 Apply Theme Now")
        apply_now_btn.connect("clicked", lambda b: self.on_apply_themes(b))
        actions_box.pack_start(apply_now_btn, False, False, 0)
        
        fonts_now_btn = Gtk.Button(label="📝 Install Fonts Now")
        fonts_now_btn.connect("clicked", self.on_install_fonts_only)
        actions_box.pack_start(fonts_now_btn, False, False, 0)
        
        reset_btn = Gtk.Button(label="🔄 Reset to Defaults")
        reset_btn.connect("clicked", self.on_reset_desktop_defaults)
        actions_box.pack_start(reset_btn, False, False, 0)
        
        return box
    
    def build_install_tab(self) -> Gtk.Box:
        """Build installation tab with terminal"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        box.set_margin_bottom(10)
        
        # Info label
        info = Gtk.Label(label="Installation progress will appear below:")
        info.set_halign(Gtk.Align.START)
        box.pack_start(info, False, False, 0)
        
        # Terminal widget
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        self.terminal = Vte.Terminal()
        self.terminal.set_font(Pango.FontDescription("Monospace 10"))
        self.terminal.set_scroll_on_output(True)
        scrolled.add(self.terminal)
        
        # Progress bar
        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_show_text(True)
        box.pack_start(self.progress_bar, False, False, 0)
        
        return box
    
    def build_status_tab(self) -> Gtk.Box:
        """Build status overview tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        # Status text view
        self.status_view = Gtk.TextView()
        self.status_view.set_editable(False)
        self.status_view.set_wrap_mode(Gtk.WrapMode.WORD)
        self.status_view.set_left_margin(10)
        self.status_view.set_right_margin(10)
        self.status_buffer = self.status_view.get_buffer()
        scrolled.add(self.status_view)
        
        # Refresh button
        refresh_btn = Gtk.Button(label="🔄 Refresh Status")
        refresh_btn.connect("clicked", self.on_refresh_status)
        box.pack_start(refresh_btn, False, False, 0)
        
        # Load initial status
        self.update_status_view()
        
        return box
    
    def on_app_toggled(self, checkbox, app_id):
        """Handle app checkbox toggle"""
        if checkbox.get_active():
            self.selected_apps.add(app_id)
        else:
            self.selected_apps.discard(app_id)
    
    def on_lang_toggled(self, checkbox, lang_id):
        """Handle language checkbox toggle"""
        if checkbox.get_active():
            self.selected_languages.add(lang_id)
        else:
            self.selected_languages.discard(lang_id)
    
    def on_container_toggled(self, checkbox, container_id):
        """Handle container checkbox toggle"""
        if checkbox.get_active():
            self.selected_containers.add(container_id)
        else:
            self.selected_containers.discard(container_id)
    
    def on_theme_selected(self, radio, theme_name):
        """Handle theme selection"""
        if radio.get_active():
            self.selected_theme = theme_name
    
    def on_install_fonts_only(self, button):
        """Install just fonts"""
        confirm = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Install Fonts"
        )
        confirm.format_secondary_text(
            "This will download and install:\n"
            "• Cascadia Mono (Nerd Font)\n"
            "• iA Writer Mono\n\n"
            "Continue?"
        )
        
        response = confirm.run()
        confirm.destroy()
        
        if response != Gtk.ResponseType.YES:
            return
        
        # Run in thread
        thread = threading.Thread(target=self.install_fonts_worker)
        thread.daemon = True
        thread.start()
    
    def install_fonts_worker(self):
        """Install fonts in background"""
        try:
            fonts_script = self.omakub_path / 'install/desktop/fonts.sh'
            if fonts_script.exists():
                subprocess.run(['bash', str(fonts_script)], timeout=300, check=True)
            
            GLib.idle_add(self.on_fonts_complete)
        except Exception as e:
            GLib.idle_add(self.on_themes_error, str(e))
    
    def on_fonts_complete(self):
        """Handle fonts installation complete"""
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Fonts Installed!"
        )
        dialog.format_secondary_text(
            "Fonts have been installed successfully.\n\n"
            "Restart applications to use the new fonts."
        )
        dialog.run()
        dialog.destroy()
    
    def on_reset_desktop_defaults(self, button):
        """Reset desktop settings to defaults"""
        confirm = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.WARNING,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Reset to Defaults"
        )
        confirm.format_secondary_text(
            "This will reset desktop customization options to defaults:\n"
            "• Theme: Tokyo Night\n"
            "• All fonts: Enabled\n"
            "• All GNOME settings: Enabled\n\n"
            "Your current selections will be lost. Continue?"
        )
        
        response = confirm.run()
        confirm.destroy()
        
        if response != Gtk.ResponseType.YES:
            return
        
        # Reset to defaults
        if hasattr(self, 'theme_radios') and 'tokyo-night' in self.theme_radios:
            self.theme_radios['tokyo-night'].set_active(True)
        
        self.install_fonts_cb.set_active(True)
        self.install_ia_fonts_cb.set_active(True)
        self.set_wallpaper_cb.set_active(True)
        self.gnome_settings_cb.set_active(True)
        self.gnome_hotkeys_cb.set_active(True)
        self.gnome_extensions_cb.set_active(False)
        
        info = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Defaults Restored"
        )
        info.format_secondary_text("Desktop customization options reset to defaults.")
        info.run()
        info.destroy()
    
    def on_save_config(self, button):
        """Save configuration to file"""
        self.save_config()
        
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Configuration Saved"
        )
        dialog.format_secondary_text(
            f"Configuration saved to:\n{self.config_path}"
        )
        dialog.run()
        dialog.destroy()
    
    def on_apply_themes(self, button):
        """Apply themes and fonts manually"""
        # Confirm action
        confirm = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Apply Themes & Fonts"
        )
        confirm.format_secondary_text(
            "This will:\n"
            "• Download and install fonts (Cascadia Mono, iA Writer)\n"
            "• Apply Tokyo Night GNOME theme\n"
            "• Set wallpaper\n"
            "• Configure GNOME settings\n\n"
            "Continue?"
        )
        
        response = confirm.run()
        confirm.destroy()
        
        if response != Gtk.ResponseType.YES:
            return
        
        # Run in thread
        thread = threading.Thread(target=self.apply_themes_worker)
        thread.daemon = True
        thread.start()
    
    def apply_themes_worker(self):
        """Apply themes in background"""
        try:
            # Install fonts
            fonts_script = self.omakub_path / 'install/desktop/fonts.sh'
            if fonts_script.exists():
                subprocess.run(['bash', str(fonts_script)], timeout=300, check=True)
            
            # Apply theme
            theme_script = self.omakub_path / 'install/desktop/set-gnome-theme.sh'
            if theme_script.exists():
                subprocess.run(
                    ['bash', str(theme_script)],
                    env={**os.environ, 'OMAKUB_PATH': str(self.omakub_path)},
                    timeout=60,
                    check=True
                )
            
            # Apply settings
            settings_script = self.omakub_path / 'install/desktop/set-gnome-settings.sh'
            if settings_script.exists():
                subprocess.run(['bash', str(settings_script)], timeout=60, check=True)
            
            GLib.idle_add(self.on_themes_complete)
            
        except Exception as e:
            GLib.idle_add(self.on_themes_error, str(e))
    
    def on_themes_complete(self):
        """Handle themes completion"""
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Themes & Fonts Applied!"
        )
        dialog.format_secondary_text(
            "Desktop customization complete.\n\n"
            "Log out and back in for all changes to take effect."
        )
        dialog.run()
        dialog.destroy()
    
    def on_themes_error(self, error_msg):
        """Handle themes error"""
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text="Theme Application Error"
        )
        dialog.format_secondary_text(error_msg)
        dialog.run()
        dialog.destroy()
    
    def on_start_install(self, button):
        """Start the installation process"""
        # Save config first
        self.save_config()
        
        # Disable install button
        self.install_btn.set_sensitive(False)
        self.install_btn.set_label("⏳ Installing...")
        
        # Reset progress
        self.progress_bar.set_fraction(0)
        self.progress_bar.set_text("Starting installation...")
        
        # Run installation in thread
        thread = threading.Thread(target=self.run_installation)
        thread.daemon = True
        thread.start()
    
    def run_installation(self):
        """Run the installation in background thread"""
        try:
            # Spawn the orchestrator in the terminal
            self.terminal.spawn_sync(
                Vte.PtyFlags.DEFAULT,
                str(self.omakub_path),
                ["python3", str(self.omakub_path / "install/orchestrator.py")],
                None,
                GLib.SpawnFlags.DO_NOT_REAP_CHILD,
                None,
                None,
            )
            
            # Update UI when complete
            GLib.idle_add(self.on_install_complete)
            
        except Exception as e:
            GLib.idle_add(self.on_install_error, str(e))
    
    def on_install_complete(self):
        """Handle installation completion"""
        self.install_btn.set_sensitive(True)
        self.install_btn.set_label("🚀 Start Installation")
        self.progress_bar.set_fraction(1.0)
        self.progress_bar.set_text("Installation complete!")
        
        # Refresh status
        self.state = self.load_state()
        self.update_status_view()
        
        # Show success dialog
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Installation Complete!"
        )
        dialog.format_secondary_text(
            "Bentobox installation finished.\nCheck the Status tab for details."
        )
        dialog.run()
        dialog.destroy()
    
    def on_install_error(self, error_msg):
        """Handle installation error"""
        self.install_btn.set_sensitive(True)
        self.install_btn.set_label("🚀 Start Installation")
        
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text="Installation Error"
        )
        dialog.format_secondary_text(error_msg)
        dialog.run()
        dialog.destroy()
    
    def on_refresh_status(self, button):
        """Refresh status view"""
        self.state = self.load_state()
        self.update_status_view()
    
    def update_status_view(self):
        """Update the status view with current state"""
        if not self.state or 'components' not in self.state:
            text = "No installation state found.\n\nRun an installation to see status here."
        else:
            components = self.state['components']
            
            # Count statuses
            installed = sum(1 for c in components.values() if c['status'] == 'installed')
            already = sum(1 for c in components.values() if c['status'] == 'already_installed')
            failed = sum(1 for c in components.values() if c['status'] == 'failed')
            skipped = sum(1 for c in components.values() if c['status'] == 'skipped')
            
            text = f"📊 Installation Status\n\n"
            text += f"✅ Installed this run: {installed}\n"
            text += f"📦 Already installed: {already}\n"
            text += f"⚠️  Failed: {failed}\n"
            text += f"⏭️  Skipped: {skipped}\n"
            text += f"\n{'─' * 50}\n\n"
            
            # List all components
            text += "Component Details:\n\n"
            for name, info in sorted(components.items()):
                status = info['status']
                icon = {
                    'installed': '✅',
                    'already_installed': '📦',
                    'failed': '⚠️',
                    'skipped': '⏭️',
                    'installing': '⏳'
                }.get(status, '❓')
                
                text += f"{icon} {name}: {status}\n"
                if info.get('error'):
                    text += f"   Error: {info['error']}\n"
        
        self.status_buffer.set_text(text)
    
    def run(self):
        """Start the GUI main loop"""
        Gtk.main()

def main():
    # Check if we have display
    if not os.environ.get('DISPLAY') and not os.environ.get('WAYLAND_DISPLAY'):
        print("❌ No display detected. GUI requires a graphical session.")
        print("   Run this from the desktop, not over SSH.")
        sys.exit(1)
    
    # Check dependencies
    try:
        import yaml
    except ImportError:
        print("Installing PyYAML...")
        subprocess.run([sys.executable, "-m", "pip", "install", "--user", "pyyaml"])
        import yaml
    
    app = BentoboxGUI()
    app.run()

if __name__ == '__main__':
    main()

