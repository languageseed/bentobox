#!/usr/bin/env python3
"""
Bentobox GUI Installer
Simple desktop interface for managing Bentobox installation
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Vte', '2.91')
gi.require_version('GdkPixbuf', '2.0')
from gi.repository import Gtk, GLib, Vte, Pango, Gdk, GdkPixbuf

import os
import sys
import json
import yaml
import subprocess
import threading
import requests
import io
from pathlib import Path
from typing import Dict, List, Optional
from PIL import Image

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
        
        # Apply styling before building UI
        self.apply_styling()
        
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
    
    def apply_styling(self):
        """Apply custom CSS styling to the application"""
        css_provider = Gtk.CssProvider()
        css = b"""
        /* Notebook tabs styling - keep purple accent */
        notebook > header > tabs > tab:checked {
            color: #7C4DFF;
            border-bottom: 3px solid #7C4DFF;
        }
        
        notebook > header > tabs > tab:hover {
            background-color: rgba(124, 77, 255, 0.1);
        }
        
        /* Buttons - keep purple for primary actions only */
        button.suggested-action {
            background-image: linear-gradient(to bottom, #7C4DFF, #651FFF);
            color: white;
            border: none;
        }
        
        button.suggested-action:hover {
            background-image: linear-gradient(to bottom, #8C5DFF, #751FFF);
        }
        
        /* Destructive action button - red */
        button.destructive-action {
            background-image: linear-gradient(to bottom, #e74c3c, #c0392b);
            color: white;
            border: none;
        }
        
        button.destructive-action:hover {
            background-image: linear-gradient(to bottom, #f05545, #d52b1e);
        }
        
        /* Check buttons and radio buttons - subtle hover */
        checkbutton:hover, radiobutton:hover {
            background-color: rgba(124, 77, 255, 0.05);
            border-radius: 4px;
        }
        
        /* Progress bar - purple */
        progressbar progress {
            background-image: linear-gradient(to bottom, #7C4DFF, #651FFF);
        }
        """
        
        css_provider.load_from_data(css)
        
        # Apply to default screen
        screen = Gdk.Screen.get_default()
        style_context = Gtk.StyleContext()
        style_context.add_provider_for_screen(
            screen,
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
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
                'install_extensions': self.gnome_extensions_cb.get_active() if hasattr(self, 'gnome_extensions_cb') else True,
            },
            'languages': list(self.selected_languages),
            'containers': list(self.selected_containers),
            'security': {
                'enable_ufw': self.ufw_enable_cb.get_active() if hasattr(self, 'ufw_enable_cb') else False,
                'ufw_deny_incoming': self.ufw_deny_incoming_cb.get_active() if hasattr(self, 'ufw_deny_incoming_cb') else False,
                'ufw_allow_ssh': self.ufw_allow_ssh_cb.get_active() if hasattr(self, 'ufw_allow_ssh_cb') else False,
                'unattended_upgrades': self.unattended_upgrades_cb.get_active() if hasattr(self, 'unattended_upgrades_cb') else False,
                'install_fail2ban': self.fail2ban_cb.get_active() if hasattr(self, 'fail2ban_cb') else False,
                'disable_root_login': self.disable_root_login_cb.get_active() if hasattr(self, 'disable_root_login_cb') else False,
                'password_required': self.password_required_cb.get_active() if hasattr(self, 'password_required_cb') else False,
                'ssh_key_only': self.ssh_key_only_cb.get_active() if hasattr(self, 'ssh_key_only_cb') else False,
                'ssh_change_port': self.ssh_change_port_cb.get_active() if hasattr(self, 'ssh_change_port_cb') else False,
                'disable_apport': self.disable_apport_cb.get_active() if hasattr(self, 'disable_apport_cb') else False,
                'disable_popularity_contest': self.disable_popularity_contest_cb.get_active() if hasattr(self, 'disable_popularity_contest_cb') else False,
            },
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
        self.window.set_default_size(1000, 750)
        self.window.connect("destroy", Gtk.main_quit)
        
        # Header bar - use default system styling
        header_bar = Gtk.HeaderBar()
        header_bar.set_title("Bentobox Installer")
        header_bar.set_subtitle("Transform Your Ubuntu Workspace")
        header_bar.set_show_close_button(True)
        self.window.set_titlebar(header_bar)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        main_box.set_margin_start(10)
        main_box.set_margin_end(10)
        main_box.set_margin_bottom(10)
        self.window.add(main_box)
        
        # Notebook for tabs (save as instance variable for later access)
        self.notebook = Gtk.Notebook()
        main_box.pack_start(self.notebook, True, True, 0)
        
        # Tab 0: Welcome/Instructions
        welcome_box = self.build_welcome_tab()
        self.notebook.append_page(welcome_box, Gtk.Label(label="👋 Welcome"))
        
        # Tab 1: Component Selection
        selection_box = self.build_selection_tab()
        self.notebook.append_page(selection_box, Gtk.Label(label="📦 Components"))
        
        # Tab 2: Desktop Customization
        desktop_box = self.build_desktop_tab()
        self.notebook.append_page(desktop_box, Gtk.Label(label="🎨 Desktop"))
        
        # Tab 3: Security
        security_box = self.build_security_tab()
        self.notebook.append_page(security_box, Gtk.Label(label="🔒 Security"))
        
        # Tab 4: Wallpapers
        wallpaper_box = self.build_wallpaper_tab()
        self.notebook.append_page(wallpaper_box, Gtk.Label(label="🖼️  Wallpapers"))
        
        # Tab 5: Installation
        install_box = self.build_install_tab()
        self.notebook.append_page(install_box, Gtk.Label(label="▶️  Install"))
        
        # Tab 6: Status
        status_box = self.build_status_tab()
        self.notebook.append_page(status_box, Gtk.Label(label="📊 Status"))
        
        # Tab 7: Maintenance (Uninstall)
        maintenance_box = self.build_maintenance_tab()
        self.notebook.append_page(maintenance_box, Gtk.Label(label="⚙️  Maintenance"))
        
        # Bottom button bar
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        button_box.set_margin_top(10)
        button_box.set_margin_start(10)
        button_box.set_margin_end(10)
        button_box.set_margin_bottom(10)
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
    
    def build_welcome_tab(self) -> Gtk.Box:
        """Build welcome/instructions tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        # Content box with nice padding
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        content.set_margin_start(40)
        content.set_margin_end(40)
        content.set_margin_top(30)
        content.set_margin_bottom(30)
        scrolled.add(content)
        
        # Hero section
        hero_label = Gtk.Label()
        hero_label.set_markup(
            "<span size='xx-large' weight='bold'>🚀 Welcome to Bentobox Installer</span>\n"
            "<span size='large'>Transform your Ubuntu into a beautiful, productive workspace</span>"
        )
        hero_label.set_justify(Gtk.Justification.CENTER)
        hero_label.set_line_wrap(True)
        hero_label.set_margin_bottom(20)
        content.pack_start(hero_label, False, False, 0)
        
        # Separator
        sep1 = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        content.pack_start(sep1, False, False, 0)
        
        # What is Bentobox section
        what_label = Gtk.Label()
        what_label.set_markup("<span size='x-large' weight='bold'>What is Bentobox?</span>")
        what_label.set_halign(Gtk.Align.START)
        what_label.set_margin_top(10)
        content.pack_start(what_label, False, False, 0)
        
        what_desc = Gtk.Label()
        what_desc.set_markup(
            "Bentobox is a <b>complete development environment installer</b> for Ubuntu 24.04.\n"
            "It includes everything you need to get started with coding, design, and productivity:\n\n"
            "• <b>Modern Applications</b> - VS Code, Cursor, Chrome, Docker, and more\n"
            "• <b>Beautiful Themes</b> - Tokyo Night, Gruvbox, Nord, and other carefully curated themes\n"
            "• <b>Programming Languages</b> - Node.js, Python, Ruby, Go, Rust, and more\n"
            "• <b>Developer Tools</b> - Docker containers, terminal tools, fonts, and utilities\n"
            "• <b>Smart Installation</b> - Detects existing packages and skips them automatically"
        )
        what_desc.set_halign(Gtk.Align.START)
        what_desc.set_line_wrap(True)
        what_desc.set_margin_start(20)
        what_desc.set_margin_top(10)
        content.pack_start(what_desc, False, False, 0)
        
        # Separator
        sep2 = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        sep2.set_margin_top(20)
        content.pack_start(sep2, False, False, 0)
        
        # How to use section
        how_label = Gtk.Label()
        how_label.set_markup("<span size='x-large' weight='bold'>How to Use This Installer</span>")
        how_label.set_halign(Gtk.Align.START)
        how_label.set_margin_top(10)
        content.pack_start(how_label, False, False, 0)
        
        # Step by step with nice formatting
        steps = [
            ("1️⃣", "Choose Your Apps", "Go to the <b>📦 Components</b> tab and select the applications, languages, and containers you want to install."),
            ("2️⃣", "Customize Your Desktop", "Visit the <b>🎨 Desktop</b> tab to pick your theme, fonts, and desktop settings."),
            ("3️⃣", "Save Your Choices", "Click <b>💾 Save Configuration</b> to save your selections."),
            ("4️⃣", "Start Installation", "Go to the <b>▶️  Install</b> tab and click <b>🚀 Start Installation</b> to begin."),
            ("5️⃣", "Watch Progress", "Monitor the installation in real-time through the embedded terminal."),
            ("6️⃣", "Check Status", "View installation results in the <b>📊 Status</b> tab when complete."),
        ]
        
        for emoji, title, desc in steps:
            step_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
            step_box.set_margin_start(20)
            step_box.set_margin_top(10)
            
            emoji_label = Gtk.Label()
            emoji_label.set_markup(f"<span size='x-large'>{emoji}</span>")
            emoji_label.set_valign(Gtk.Align.START)
            step_box.pack_start(emoji_label, False, False, 0)
            
            text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
            
            step_title = Gtk.Label()
            step_title.set_markup(f"<span size='large' weight='bold'>{title}</span>")
            step_title.set_halign(Gtk.Align.START)
            text_box.pack_start(step_title, False, False, 0)
            
            step_desc = Gtk.Label()
            step_desc.set_markup(desc)
            step_desc.set_halign(Gtk.Align.START)
            step_desc.set_line_wrap(True)
            step_desc.set_max_width_chars(60)
            text_box.pack_start(step_desc, False, False, 0)
            
            step_box.pack_start(text_box, True, True, 0)
            content.pack_start(step_box, False, False, 0)
        
        # Separator
        sep3 = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        sep3.set_margin_top(20)
        content.pack_start(sep3, False, False, 0)
        
        # Features section
        features_label = Gtk.Label()
        features_label.set_markup("<span size='x-large' weight='bold'>✨ Key Features</span>")
        features_label.set_halign(Gtk.Align.START)
        features_label.set_margin_top(10)
        content.pack_start(features_label, False, False, 0)
        
        features_grid = Gtk.Grid()
        features_grid.set_row_spacing(10)
        features_grid.set_column_spacing(20)
        features_grid.set_margin_start(20)
        features_grid.set_margin_top(10)
        
        features = [
            ("✅", "Safe & Idempotent", "Can be run multiple times safely"),
            ("🔍", "Smart Detection", "Skips already-installed packages"),
            ("🎨", "Beautiful Themes", "10+ carefully curated color schemes"),
            ("⚡", "Fast & Reliable", "Robust error handling and state tracking"),
            ("📝", "Complete Documentation", "Detailed guides for everything"),
            ("🔧", "Easy Customization", "Pick exactly what you want"),
        ]
        
        row = 0
        col = 0
        for emoji, title, desc in features:
            feature_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            
            feature_emoji = Gtk.Label()
            feature_emoji.set_markup(f"<span size='large'>{emoji}</span>")
            feature_box.pack_start(feature_emoji, False, False, 0)
            
            feature_text = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            feature_title = Gtk.Label()
            feature_title.set_markup(f"<b>{title}</b>")
            feature_title.set_halign(Gtk.Align.START)
            feature_text.pack_start(feature_title, False, False, 0)
            
            feature_desc = Gtk.Label(label=desc)
            feature_desc.set_halign(Gtk.Align.START)
            feature_desc.get_style_context().add_class('dim-label')
            feature_text.pack_start(feature_desc, False, False, 0)
            
            feature_box.pack_start(feature_text, True, True, 0)
            features_grid.attach(feature_box, col, row, 1, 1)
            
            col += 1
            if col > 1:
                col = 0
                row += 1
        
        content.pack_start(features_grid, False, False, 0)
        
        # Call to action
        cta_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        cta_box.set_margin_top(30)
        cta_box.set_halign(Gtk.Align.CENTER)
        
        cta_label = Gtk.Label()
        cta_label.set_markup("<span size='large' weight='bold'>Ready to get started?</span>")
        cta_box.pack_start(cta_label, False, False, 0)
        
        cta_button = Gtk.Button(label="📦 Choose Components →")
        cta_button.set_size_request(250, 50)
        cta_button.get_style_context().add_class('suggested-action')
        cta_button.connect("clicked", lambda b: self.notebook.set_current_page(1))
        cta_box.pack_start(cta_button, False, False, 0)
        
        content.pack_start(cta_box, False, False, 0)
        
        return box
    
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
        
        # Content box - HORIZONTAL for 3 columns
        content = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=20)
        content.set_margin_start(10)
        content.set_margin_end(10)
        content.set_margin_top(10)
        content.set_homogeneous(True)
        scrolled.add(content)
        
        # === COLUMN 1: Desktop Applications ===
        apps_column = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        apps_label = Gtk.Label()
        apps_label.set_markup("<b>Desktop Applications</b>")
        apps_label.set_halign(Gtk.Align.START)
        apps_column.pack_start(apps_label, False, False, 0)
        
        apps = [
            ("1password", "1Password"),
            ("blender", "Blender"),
            ("brave", "Brave Browser"),
            ("chrome", "Chrome"),
            ("cursor", "Cursor"),
            ("drawio", "Draw.io"),
            ("foliate", "Foliate (eBook Reader)"),
            ("gimp", "GIMP"),
            ("kooha", "Kooha (Screen Recorder)"),
            ("logseq", "Logseq"),
            ("mission-center", "Mission Center"),
            ("obs-studio", "OBS Studio"),
            ("portmaster", "Portmaster (Firewall)"),
            ("reaper", "REAPER (DAW)"),
            ("rubymine", "RubyMine"),
            ("sublime-text", "Sublime Text"),
            ("tailscale", "Tailscale"),
            ("timeshift", "Timeshift"),
            ("warp", "Warp Terminal"),
            ("winboat", "WinBoat"),
            ("download-windows10-iso", "Windows 10 ISO Download"),
        ]
        
        apps_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        apps_box.set_margin_start(10)
        apps_column.pack_start(apps_box, False, False, 0)
        
        for app_id, app_name in apps:
            cb = Gtk.CheckButton(label=app_name)
            cb.set_active(app_id in self.config.get('desktop', {}).get('optional_apps', []))
            cb.connect("toggled", self.on_app_toggled, app_id)
            apps_box.pack_start(cb, False, False, 0)
        
        content.pack_start(apps_column, True, True, 0)
        
        # === COLUMN 2: Programming Languages ===
        lang_column = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        lang_label = Gtk.Label()
        lang_label.set_markup("<b>Programming Languages</b>")
        lang_label.set_halign(Gtk.Align.START)
        lang_column.pack_start(lang_label, False, False, 0)
        
        languages = [
            ("Node.js", "Node.js"),
            ("Python", "Python"),
            ("Ruby on Rails", "Ruby on Rails"),
            ("Go", "Go"),
            ("PHP", "PHP"),
            ("Elixir", "Elixir"),
            ("Rust", "Rust"),
            ("Java", "Java"),
        ]
        
        lang_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        lang_box.set_margin_start(10)
        lang_column.pack_start(lang_box, False, False, 0)
        
        for lang_id, lang_name in languages:
            cb = Gtk.CheckButton(label=lang_name)
            cb.set_active(lang_id in self.config.get('languages', []))
            cb.connect("toggled", self.on_lang_toggled, lang_id)
            lang_box.pack_start(cb, False, False, 0)
        
        content.pack_start(lang_column, True, True, 0)
        
        # === COLUMN 3: Docker Containers ===
        container_column = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        container_label = Gtk.Label()
        container_label.set_markup("<b>Docker Containers</b>")
        container_label.set_halign(Gtk.Align.START)
        container_column.pack_start(container_label, False, False, 0)
        
        containers = [
            ("Portainer", "Portainer"),
            ("OpenWebUI", "OpenWebUI"),
            ("Ollama", "Ollama"),
        ]
        
        container_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        container_box.set_margin_start(10)
        container_column.pack_start(container_box, False, False, 0)
        
        for container_id, container_name in containers:
            cb = Gtk.CheckButton(label=container_name)
            cb.set_active(container_id in self.config.get('containers', []))
            cb.connect("toggled", self.on_container_toggled, container_id)
            container_box.pack_start(cb, False, False, 0)
        
        content.pack_start(container_column, True, True, 0)
        
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
        self.gnome_extensions_cb.set_active(self.config.get('desktop', {}).get('install_extensions', True))
        gnome_box.pack_start(self.gnome_extensions_cb, False, False, 0)
        
        # Extension list (shown when checkbox is checked)
        extensions_info = Gtk.Label()
        extensions_info.set_markup(
            "<small><i>Extensions to be installed:</i>\n"
            "• <b>Tactile</b> - Advanced window tiling\n"
            "• <b>Just Perfection</b> - Customize GNOME Shell\n"
            "• <b>Blur My Shell</b> - Beautiful blur effects\n"
            "• <b>Space Bar</b> - Workspace indicator\n"
            "• <b>Undecorate</b> - Remove window decorations\n"
            "• <b>TopHat</b> - System resource monitor in top bar\n"
            "• <b>Alphabetical App Grid</b> - Sort applications alphabetically</small>"
        )
        extensions_info.set_halign(Gtk.Align.START)
        extensions_info.set_margin_start(40)
        extensions_info.set_margin_top(5)
        extensions_info.set_line_wrap(True)
        gnome_box.pack_start(extensions_info, False, False, 0)
        
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
    
    def build_security_tab(self) -> Gtk.Box:
        """Build security hardening configuration tab"""
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
        
        # Header
        header = Gtk.Label()
        header.set_markup("<big><b>🔒 Security Configuration</b></big>")
        header.set_halign(Gtk.Align.START)
        content.pack_start(header, False, False, 0)
        
        info = Gtk.Label()
        info.set_markup("<i>Configure security hardening options for your system</i>")
        info.set_halign(Gtk.Align.START)
        content.pack_start(info, False, False, 0)
        
        # === FIREWALL SECTION ===
        firewall_label = Gtk.Label()
        firewall_label.set_markup("<b>🛡️  Firewall (UFW)</b>")
        firewall_label.set_halign(Gtk.Align.START)
        firewall_label.set_margin_top(10)
        content.pack_start(firewall_label, False, False, 0)
        
        firewall_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        firewall_box.set_margin_start(20)
        content.pack_start(firewall_box, False, False, 0)
        
        self.ufw_enable_cb = Gtk.CheckButton(label="Enable UFW firewall")
        self.ufw_enable_cb.set_active(self.config.get('security', {}).get('enable_ufw', False))
        firewall_box.pack_start(self.ufw_enable_cb, False, False, 0)
        
        self.ufw_deny_incoming_cb = Gtk.CheckButton(label="Deny all incoming connections by default")
        self.ufw_deny_incoming_cb.set_active(self.config.get('security', {}).get('ufw_deny_incoming', False))
        firewall_box.pack_start(self.ufw_deny_incoming_cb, False, False, 0)
        
        self.ufw_allow_ssh_cb = Gtk.CheckButton(label="Allow SSH (port 22)")
        self.ufw_allow_ssh_cb.set_active(self.config.get('security', {}).get('ufw_allow_ssh', False))
        firewall_box.pack_start(self.ufw_allow_ssh_cb, False, False, 0)
        
        # === SYSTEM HARDENING ===
        hardening_label = Gtk.Label()
        hardening_label.set_markup("<b>🔐 System Hardening</b>")
        hardening_label.set_halign(Gtk.Align.START)
        hardening_label.set_margin_top(10)
        content.pack_start(hardening_label, False, False, 0)
        
        hardening_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        hardening_box.set_margin_start(20)
        content.pack_start(hardening_box, False, False, 0)
        
        self.unattended_upgrades_cb = Gtk.CheckButton(label="Enable automatic security updates")
        self.unattended_upgrades_cb.set_active(self.config.get('security', {}).get('unattended_upgrades', False))
        hardening_box.pack_start(self.unattended_upgrades_cb, False, False, 0)
        
        self.fail2ban_cb = Gtk.CheckButton(label="Install Fail2Ban (intrusion prevention)")
        self.fail2ban_cb.set_active(self.config.get('security', {}).get('install_fail2ban', False))
        hardening_box.pack_start(self.fail2ban_cb, False, False, 0)
        
        self.disable_root_login_cb = Gtk.CheckButton(label="Disable root SSH login")
        self.disable_root_login_cb.set_active(self.config.get('security', {}).get('disable_root_login', False))
        hardening_box.pack_start(self.disable_root_login_cb, False, False, 0)
        
        self.password_required_cb = Gtk.CheckButton(label="Require password for sudo")
        self.password_required_cb.set_active(self.config.get('security', {}).get('password_required', False))
        hardening_box.pack_start(self.password_required_cb, False, False, 0)
        
        # === SSH HARDENING ===
        ssh_label = Gtk.Label()
        ssh_label.set_markup("<b>🔑 SSH Security</b>")
        ssh_label.set_halign(Gtk.Align.START)
        ssh_label.set_margin_top(10)
        content.pack_start(ssh_label, False, False, 0)
        
        ssh_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        ssh_box.set_margin_start(20)
        content.pack_start(ssh_box, False, False, 0)
        
        self.ssh_key_only_cb = Gtk.CheckButton(label="Disable password authentication (key-only)")
        self.ssh_key_only_cb.set_active(self.config.get('security', {}).get('ssh_key_only', False))
        ssh_box.pack_start(self.ssh_key_only_cb, False, False, 0)
        
        self.ssh_change_port_cb = Gtk.CheckButton(label="Change SSH port from 22 to 2222")
        self.ssh_change_port_cb.set_active(self.config.get('security', {}).get('ssh_change_port', False))
        ssh_box.pack_start(self.ssh_change_port_cb, False, False, 0)
        
        # === PRIVACY ===
        privacy_label = Gtk.Label()
        privacy_label.set_markup("<b>🕵️  Privacy</b>")
        privacy_label.set_halign(Gtk.Align.START)
        privacy_label.set_margin_top(10)
        content.pack_start(privacy_label, False, False, 0)
        
        privacy_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        privacy_box.set_margin_start(20)
        content.pack_start(privacy_box, False, False, 0)
        
        self.disable_apport_cb = Gtk.CheckButton(label="Disable error reporting (apport)")
        self.disable_apport_cb.set_active(self.config.get('security', {}).get('disable_apport', False))
        privacy_box.pack_start(self.disable_apport_cb, False, False, 0)
        
        self.disable_popularity_contest_cb = Gtk.CheckButton(label="Disable popularity contest")
        self.disable_popularity_contest_cb.set_active(self.config.get('security', {}).get('disable_popularity_contest', False))
        privacy_box.pack_start(self.disable_popularity_contest_cb, False, False, 0)
        
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
        
        apply_security_btn = Gtk.Button(label="🔒 Apply Security Settings Now")
        apply_security_btn.get_style_context().add_class('suggested-action')
        apply_security_btn.connect("clicked", self.on_apply_security)
        actions_box.pack_start(apply_security_btn, False, False, 0)
        
        audit_btn = Gtk.Button(label="🔍 Run Security Audit")
        audit_btn.connect("clicked", self.on_security_audit)
        actions_box.pack_start(audit_btn, False, False, 0)
        
        return box
    
    def build_install_tab(self) -> Gtk.Box:
        """Build installation tab with terminal"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        box.set_margin_bottom(10)
        
        # Info label
        self.install_info_label = Gtk.Label(label="Installation progress will appear below:")
        self.install_info_label.set_halign(Gtk.Align.START)
        box.pack_start(self.install_info_label, False, False, 0)
        
        # Terminal widget
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        self.terminal = Vte.Terminal()
        self.terminal.set_font(Pango.FontDescription("Monospace 10"))
        self.terminal.set_scroll_on_output(True)
        scrolled.add(self.terminal)
        
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
    
    def build_maintenance_tab(self) -> Gtk.Box:
        """Build maintenance/uninstall tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(20)
        box.set_margin_start(20)
        box.set_margin_end(20)
        box.set_margin_bottom(20)
        
        # Header
        header = Gtk.Label()
        header.set_markup("<big><b>⚙️  System Maintenance</b></big>")
        header.set_halign(Gtk.Align.START)
        header.set_margin_bottom(10)
        box.pack_start(header, False, False, 0)
        
        # Info section
        info_frame = Gtk.Frame()
        info_frame.set_margin_bottom(20)
        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        info_box.set_margin_start(15)
        info_box.set_margin_end(15)
        info_box.set_margin_top(15)
        info_box.set_margin_bottom(15)
        
        info_label = Gtk.Label()
        info_label.set_markup(
            "<b>System Reset Options</b>\n\n"
            "Use these tools to manage or remove Bentobox components from your system."
        )
        info_label.set_line_wrap(True)
        info_label.set_halign(Gtk.Align.START)
        info_box.pack_start(info_label, False, False, 0)
        info_frame.add(info_box)
        box.pack_start(info_frame, False, False, 0)
        
        # Spacer
        box.pack_start(Gtk.Label(), True, True, 0)
        
        # Uninstall section
        uninstall_frame = Gtk.Frame()
        uninstall_frame.set_label(" ⚠️  Danger Zone ")
        uninstall_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        uninstall_box.set_margin_start(20)
        uninstall_box.set_margin_end(20)
        uninstall_box.set_margin_top(20)
        uninstall_box.set_margin_bottom(20)
        
        warning_label = Gtk.Label()
        warning_label.set_markup(
            "<b>Uninstall Bentobox</b>\n\n"
            "This will remove all Bentobox-installed applications, configurations,\n"
            "and customizations from your system.\n\n"
            "<b>⚠️  This action cannot be undone!</b>"
        )
        warning_label.set_line_wrap(True)
        warning_label.set_justify(Gtk.Justification.CENTER)
        uninstall_box.pack_start(warning_label, False, False, 0)
        
        # Uninstall button
        uninstall_btn = Gtk.Button(label="🗑️  Uninstall & Reset System")
        uninstall_btn.set_size_request(300, 50)
        uninstall_btn.get_style_context().add_class('destructive-action')
        uninstall_btn.connect("clicked", self.on_uninstall_bentobox)
        uninstall_btn.set_halign(Gtk.Align.CENTER)
        uninstall_box.pack_start(uninstall_btn, False, False, 0)
        
        uninstall_frame.add(uninstall_box)
        box.pack_start(uninstall_frame, False, False, 0)
        
        # Spacer
        box.pack_start(Gtk.Label(), True, True, 0)
        
        return box
    
    def build_wallpaper_tab(self) -> Gtk.Box:
        """Build simple local wallpaper selector tab"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_margin_top(10)
        box.set_margin_start(10)
        box.set_margin_end(10)
        
        # Header label
        header = Gtk.Label()
        header.set_markup("<big><b>🖼️  Select Desktop Wallpaper</b></big>")
        header.set_margin_bottom(10)
        box.pack_start(header, False, False, 0)
        
        # Info label
        info = Gtk.Label()
        info.set_markup("<i>Choose from the included wallpaper collection</i>")
        info.set_margin_bottom(10)
        box.pack_start(info, False, False, 0)
        
        # Scrolled window for wallpaper grid
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        box.pack_start(scrolled, True, True, 0)
        
        # Grid for wallpapers
        self.wallpaper_grid = Gtk.FlowBox()
        self.wallpaper_grid.set_valign(Gtk.Align.START)
        self.wallpaper_grid.set_max_children_per_line(3)
        self.wallpaper_grid.set_selection_mode(Gtk.SelectionMode.NONE)
        self.wallpaper_grid.set_homogeneous(True)
        self.wallpaper_grid.set_row_spacing(15)
        self.wallpaper_grid.set_column_spacing(15)
        scrolled.add(self.wallpaper_grid)
        
        # Load local wallpapers
        self.load_local_wallpapers()
        
        return box
    
    def load_local_wallpapers(self):
        """Load wallpapers from the included collection"""
        wallpaper_dir = self.omakub_path / 'wallpaper'
        
        if not wallpaper_dir.exists():
            error_label = Gtk.Label()
            error_label.set_markup("<span color='red'>❌ Wallpaper directory not found</span>")
            self.wallpaper_grid.add(error_label)
            return
        
        # Find all jpg images in wallpaper directory
        wallpapers = sorted(wallpaper_dir.glob('*.jpg'))
        
        if not wallpapers:
            error_label = Gtk.Label()
            error_label.set_markup("<i>No wallpapers found</i>")
            self.wallpaper_grid.add(error_label)
            return
        
        for wallpaper_path in wallpapers:
            card = self.create_local_wallpaper_card(wallpaper_path)
            self.wallpaper_grid.add(card)
        
        self.wallpaper_grid.show_all()
    
    def create_local_wallpaper_card(self, wallpaper_path: Path) -> Gtk.Box:
        """Create a wallpaper card widget"""
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        card.set_size_request(250, 220)
        
        # Event box for click handling
        event_box = Gtk.EventBox()
        card.pack_start(event_box, True, True, 0)
        
        inner_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        event_box.add(inner_box)
        
        # Thumbnail image
        try:
            from PIL import Image
            
            # Load and resize image for thumbnail
            img = Image.open(wallpaper_path)
            img.thumbnail((240, 140))
            
            # Save to temp location
            temp_thumb = Path.home() / '.cache/bentobox' / f"thumb_{wallpaper_path.name}"
            temp_thumb.parent.mkdir(parents=True, exist_ok=True)
            img.save(temp_thumb, 'JPEG')
            
            # Create GTK image
            image = Gtk.Image.new_from_file(str(temp_thumb))
            image.set_size_request(240, 140)
            
        except Exception as e:
            # Fallback to icon if image loading fails
            image = Gtk.Image()
            image.set_from_icon_name("image-x-generic", Gtk.IconSize.DIALOG)
            image.set_size_request(240, 140)
        
        inner_box.pack_start(image, False, False, 0)
        
        # Wallpaper name (extract from filename)
        name = wallpaper_path.stem.replace('pexels-', '').replace('-', ' ').title()
        name_label = Gtk.Label()
        name_label.set_markup(f"<b>{name[:30]}</b>")
        name_label.set_line_wrap(True)
        name_label.set_max_width_chars(30)
        inner_box.pack_start(name_label, False, False, 0)
        
        # Apply button
        apply_btn = Gtk.Button(label="Set as Wallpaper")
        apply_btn.connect("clicked", self.on_apply_wallpaper, str(wallpaper_path))
        inner_box.pack_start(apply_btn, False, False, 0)
        
        # Add hover effect
        event_box.connect("enter-notify-event", self.on_wallpaper_hover_enter, card)
        event_box.connect("leave-notify-event", self.on_wallpaper_hover_leave, card)
        
        return card
    
    def on_wallpaper_hover_enter(self, widget, event, card):
        """Handle mouse hover enter"""
        card.set_opacity(0.8)
    
    def on_wallpaper_hover_leave(self, widget, event, card):
        """Handle mouse hover leave"""
        card.set_opacity(1.0)
    
    def on_apply_wallpaper(self, button, wallpaper_path):
        """Apply selected wallpaper"""
        # Switch to Install tab
        self.notebook.set_current_page(5)
        
        # Clear terminal and show header
        self.clear_terminal()
        self.append_to_terminal("🖼️  Applying Wallpaper\n")
        self.append_to_terminal("=" * 50 + "\n\n")
        
        # Get wallpaper name
        wallpaper_name = wallpaper_path.stem.replace('pexels-', '').replace('-', ' ').title()
        self.append_to_terminal(f"Selected wallpaper: {wallpaper_name}\n")
        self.append_to_terminal(f"Path: {wallpaper_path}\n\n")
        
        # Run in thread
        thread = threading.Thread(target=self.apply_wallpaper_worker, args=(wallpaper_path,))
        thread.daemon = True
        thread.start()
    
    def apply_wallpaper_worker(self, wallpaper_path):
        """Apply wallpaper in background"""
        try:
            # Set GNOME wallpaper
            GLib.idle_add(self.append_to_terminal, "Setting wallpaper for light mode...\n")
            result = subprocess.run([
                'gsettings', 'set', 'org.gnome.desktop.background', 'picture-uri',
                f'file://{wallpaper_path}'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                GLib.idle_add(self.append_to_terminal, "✅ Light mode wallpaper set\n\n")
            else:
                GLib.idle_add(self.append_to_terminal, f"❌ Error: {result.stderr}\n")
            
            GLib.idle_add(self.append_to_terminal, "Setting wallpaper for dark mode...\n")
            result = subprocess.run([
                'gsettings', 'set', 'org.gnome.desktop.background', 'picture-uri-dark',
                f'file://{wallpaper_path}'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                GLib.idle_add(self.append_to_terminal, "✅ Dark mode wallpaper set\n\n")
            else:
                GLib.idle_add(self.append_to_terminal, f"❌ Error: {result.stderr}\n")
            
            # Show completion message
            GLib.idle_add(self.append_to_terminal, "\n🎉 Wallpaper applied successfully!\n")
            GLib.idle_add(self.append_to_terminal, "=" * 50 + "\n")
            
        except Exception as e:
            GLib.idle_add(self.append_to_terminal, f"\n❌ Error applying wallpaper: {str(e)}\n")
        card.pack_start(title_label, False, False, 0)
        
        # Photographer
        author_label = Gtk.Label()
        author_label.set_markup(f"<small>{photo['photographer']}</small>")
        card.pack_start(author_label, False, False, 0)
        
        # Provider badge
        provider_label = Gtk.Label()
        provider_label.set_markup(f"<small><i>{photo['provider']}</i></small>")
        card.pack_start(provider_label, False, False, 0)
        
        # Buttons
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        
        download_btn = Gtk.Button(label="⬇")
        download_btn.set_tooltip_text("Download")
        download_btn.connect("clicked", self.on_download_wallpaper, photo)
        button_box.pack_start(download_btn, True, True, 0)
        
    
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
        self.gnome_extensions_cb.set_active(True)
        
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
    
    def on_apply_security(self, button):
        """Apply security settings now"""
        confirm = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Apply Security Settings"
        )
        confirm.format_secondary_text(
            "This will apply the selected security hardening options.\n\n"
            "⚠️  Warning: Some changes (like disabling password auth) may lock you out\n"
            "if not configured properly. Continue?"
        )
        
        response = confirm.run()
        confirm.destroy()
        
        if response != Gtk.ResponseType.YES:
            return
        
        # Show info that this feature is coming soon
        info = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Security Configuration"
        )
        info.format_secondary_text(
            "Security settings will be applied during installation.\n\n"
            "Click 'Save Configuration' to save your security preferences,\n"
            "then run the installation to apply them."
        )
        info.run()
        info.destroy()
    
    def on_security_audit(self, button):
        """Run a security audit"""
        # Show info dialog
        info = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Security Audit"
        )
        
        # Run basic security checks
        audit_results = []
        
        # Check if UFW is enabled
        try:
            result = subprocess.run(['sudo', 'ufw', 'status'], capture_output=True, text=True, timeout=5)
            if 'Status: active' in result.stdout:
                audit_results.append("✅ UFW firewall is active")
            else:
                audit_results.append("❌ UFW firewall is not active")
        except:
            audit_results.append("⚠️  Could not check UFW status")
        
        # Check if unattended-upgrades is installed
        try:
            result = subprocess.run(['dpkg', '-l', 'unattended-upgrades'], capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                audit_results.append("✅ Automatic security updates enabled")
            else:
                audit_results.append("❌ Automatic security updates not configured")
        except:
            audit_results.append("⚠️  Could not check unattended-upgrades")
        
        # Check if fail2ban is running
        try:
            result = subprocess.run(['systemctl', 'is-active', 'fail2ban'], capture_output=True, text=True, timeout=5)
            if result.stdout.strip() == 'active':
                audit_results.append("✅ Fail2Ban is active")
            else:
                audit_results.append("❌ Fail2Ban is not active")
        except:
            audit_results.append("⚠️  Fail2Ban not installed")
        
        # Check SSH configuration
        try:
            with open('/etc/ssh/sshd_config', 'r') as f:
                ssh_config = f.read()
                if 'PermitRootLogin no' in ssh_config or 'PermitRootLogin prohibit-password' in ssh_config:
                    audit_results.append("✅ Root SSH login is disabled")
                else:
                    audit_results.append("⚠️  Root SSH login may be enabled")
        except:
            audit_results.append("⚠️  Could not check SSH configuration")
        
        info.format_secondary_text(
            "Security Audit Results:\n\n" + "\n".join(audit_results)
        )
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
            "• Apply selected GNOME theme\n"
            "• Set wallpaper\n"
            "• Configure GNOME settings\n\n"
            "Continue?"
        )
        
        response = confirm.run()
        confirm.destroy()
        
        if response != Gtk.ResponseType.YES:
            return
        
        # Switch to Install tab
        GLib.idle_add(self.notebook.set_current_page, 5)
        
        # Clear terminal and add header
        GLib.idle_add(self.clear_terminal)
        GLib.idle_add(self.append_to_terminal, "🎨 Applying Themes & Fonts\n")
        GLib.idle_add(self.append_to_terminal, "=" * 50 + "\n\n")
        
        # Run in thread
        thread = threading.Thread(target=self.apply_themes_worker)
        thread.daemon = True
        thread.start()
    
    def apply_themes_worker(self):
        """Apply themes in background"""
        try:
            # Suppress GTK warnings in subprocess environment
            env = os.environ.copy()
            env['G_MESSAGES_DEBUG'] = ''
            
            # Install fonts
            GLib.idle_add(self.append_to_terminal, "📝 Installing fonts...\n")
            fonts_script = self.omakub_path / 'install/desktop/fonts.sh'
            if fonts_script.exists():
                result = subprocess.run(
                    ['bash', str(fonts_script)],
                    capture_output=True,
                    text=True,
                    timeout=300,
                    env=env
                )
                GLib.idle_add(self.append_to_terminal, result.stdout)
                if result.stderr:
                    GLib.idle_add(self.append_to_terminal, result.stderr)
                GLib.idle_add(self.append_to_terminal, "✅ Fonts installed\n\n")
            
            # Configure fonts
            GLib.idle_add(self.append_to_terminal, "⚙️  Configuring terminal fonts...\n")
            configure_script = self.omakub_path / 'install/desktop/configure-fonts.sh'
            if configure_script.exists():
                result = subprocess.run(
                    ['bash', str(configure_script)],
                    capture_output=True,
                    text=True,
                    timeout=60,
                    env=env
                )
                GLib.idle_add(self.append_to_terminal, result.stdout)
                if result.stderr:
                    GLib.idle_add(self.append_to_terminal, result.stderr)
                GLib.idle_add(self.append_to_terminal, "✅ Font configuration complete\n\n")
            
            # Apply theme
            GLib.idle_add(self.append_to_terminal, "🎨 Applying GNOME theme...\n")
            theme_script = self.omakub_path / 'install/desktop/set-gnome-theme.sh'
            if theme_script.exists():
                result = subprocess.run(
                    ['bash', str(theme_script)],
                    env={**env, 'OMAKUB_PATH': str(self.omakub_path)},
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                GLib.idle_add(self.append_to_terminal, result.stdout)
                if result.stderr:
                    GLib.idle_add(self.append_to_terminal, result.stderr)
                GLib.idle_add(self.append_to_terminal, "✅ Theme applied\n\n")
            
            # Apply settings
            GLib.idle_add(self.append_to_terminal, "⚙️  Applying GNOME settings...\n")
            settings_script = self.omakub_path / 'install/desktop/set-gnome-settings.sh'
            if settings_script.exists():
                result = subprocess.run(
                    ['bash', str(settings_script)],
                    capture_output=True,
                    text=True,
                    timeout=60,
                    env=env
                )
                GLib.idle_add(self.append_to_terminal, result.stdout)
                if result.stderr:
                    GLib.idle_add(self.append_to_terminal, result.stderr)
                GLib.idle_add(self.append_to_terminal, "✅ GNOME settings applied\n\n")
            
            # Set wallpaper
            GLib.idle_add(self.append_to_terminal, "🖼️  Setting wallpaper...\n")
            wallpaper_script = self.omakub_path / 'install/desktop/set-wallpaper.sh'
            if wallpaper_script.exists():
                result = subprocess.run(
                    ['bash', str(wallpaper_script)],
                    env={**env, 'OMAKUB_PATH': str(self.omakub_path)},
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                GLib.idle_add(self.append_to_terminal, result.stdout)
                if result.stderr:
                    GLib.idle_add(self.append_to_terminal, result.stderr)
                GLib.idle_add(self.append_to_terminal, "✅ Wallpaper set\n\n")
            
            GLib.idle_add(self.append_to_terminal, "\n🎉 All customizations applied!\n")
            GLib.idle_add(self.append_to_terminal, "=" * 50 + "\n")
            GLib.idle_add(self.on_themes_complete)
            
        except Exception as e:
            GLib.idle_add(self.append_to_terminal, f"\n❌ Error: {str(e)}\n")
            GLib.idle_add(self.on_themes_error, str(e))
    
    def on_themes_complete(self):
        """Handle themes completion"""
        # Just add completion message to terminal - no popup
        self.append_to_terminal("\n💡 Log out and back in for all changes to take effect.\n")
    
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
    
    def on_uninstall_bentobox(self, button):
        """Uninstall Bentobox and reset to near-default Ubuntu"""
        # Strong warning dialog
        warning = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.WARNING,
            buttons=Gtk.ButtonsType.NONE,
            text="⚠️  Uninstall Bentobox & Reset System"
        )
        warning.format_secondary_text(
            "This will:\n\n"
            "🗑️  Remove all Bentobox-installed applications\n"
            "   • Desktop apps (Cursor, VS Code, Chrome, Typora, etc.)\n"
            "   • Terminal tools (btop, fastfetch, lazygit, zellij, etc.)\n"
            "   • Flatpak apps (Pinta, GIMP)\n"
            "🎨 Reset GNOME to default theme and settings\n"
            "📝 Remove custom fonts\n"
            "🐳 Stop and remove Docker containers\n"
            "🔧 Remove development tools (mise, Node.js, etc.)\n"
            "⚙️  Reset terminal configurations\n"
            "🖼️  Reset wallpaper to default\n"
            "🗂️  Remove repository sources\n\n"
            "This action CANNOT be undone!\n\n"
            "Your personal files will NOT be deleted, but all\n"
            "Bentobox-installed applications and customizations will be removed."
        )
        
        warning.add_button("Cancel", Gtk.ResponseType.CANCEL)
        warning.add_button("Uninstall & Reset", Gtk.ResponseType.OK)
        
        # Make the OK button red
        ok_button = warning.get_widget_for_response(Gtk.ResponseType.OK)
        ok_button.get_style_context().add_class('destructive-action')
        
        response = warning.run()
        warning.destroy()
        
        if response != Gtk.ResponseType.OK:
            return
        
        # Second confirmation
        confirm = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Final Confirmation"
        )
        confirm.format_secondary_text(
            "Are you absolutely sure you want to uninstall Bentobox?\n\n"
            "Type 'UNINSTALL' in the next dialog to confirm."
        )
        
        response2 = confirm.run()
        confirm.destroy()
        
        if response2 != Gtk.ResponseType.YES:
            return
        
        # Text entry confirmation
        entry_dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.OK_CANCEL,
            text="Type UNINSTALL to confirm"
        )
        
        entry = Gtk.Entry()
        entry.set_placeholder_text("Type: UNINSTALL")
        entry.set_width_chars(30)
        
        content_area = entry_dialog.get_content_area()
        content_area.pack_start(entry, True, True, 10)
        entry_dialog.show_all()
        
        response3 = entry_dialog.run()
        typed_text = entry.get_text()
        entry_dialog.destroy()
        
        if response3 != Gtk.ResponseType.OK or typed_text != "UNINSTALL":
            info = Gtk.MessageDialog(
                transient_for=self.window,
                flags=0,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.OK,
                text="Uninstall Cancelled"
            )
            info.format_secondary_text("No changes were made to your system.")
            info.run()
            info.destroy()
            return
        
        # Proceed with uninstall
        self.run_uninstall()
    
    def run_uninstall(self):
        """Execute the uninstall process"""
        # Show progress dialog
        progress_dialog = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.NONE,
            text="Uninstalling Bentobox..."
        )
        progress_dialog.format_secondary_text(
            "This may take several minutes.\nPlease wait..."
        )
        progress_dialog.show_all()
        
        # Process events to show dialog
        while Gtk.events_pending():
            Gtk.main_iteration()
        
        # Run uninstall in thread
        thread = threading.Thread(target=self.uninstall_worker, args=(progress_dialog,))
        thread.daemon = True
        thread.start()
    
    def uninstall_worker(self, progress_dialog):
        """Perform uninstall operations"""
        try:
            uninstall_script = self.omakub_path / 'install/uninstall-bentobox.sh'
            
            if uninstall_script.exists():
                # Run the comprehensive uninstall script
                subprocess.run(
                    ['bash', str(uninstall_script)],
                    env={**os.environ, 'OMAKUB_PATH': str(self.omakub_path)},
                    timeout=600,  # 10 minute timeout
                    check=False
                )
            else:
                # Fallback: run basic cleanup
                self.basic_uninstall()
            
            GLib.idle_add(self.on_uninstall_complete, progress_dialog)
            
        except Exception as e:
            GLib.idle_add(self.on_uninstall_error, progress_dialog, str(e))
    
    def basic_uninstall(self):
        """Basic uninstall if script not found"""
        # Stop and remove Docker containers
        subprocess.run(['docker', 'stop', 'portainer', 'open-webui', 'ollama'], 
                      check=False, capture_output=True)
        subprocess.run(['docker', 'rm', 'portainer', 'open-webui', 'ollama'], 
                      check=False, capture_output=True)
        
        # Reset GNOME settings
        subprocess.run(['gsettings', 'reset', 'org.gnome.desktop.interface', 'gtk-theme'], 
                      check=False, capture_output=True)
        subprocess.run(['gsettings', 'reset', 'org.gnome.desktop.interface', 'icon-theme'], 
                      check=False, capture_output=True)
        subprocess.run(['gsettings', 'reset', 'org.gnome.desktop.background', 'picture-uri'], 
                      check=False, capture_output=True)
    
    def on_uninstall_complete(self, progress_dialog):
        """Handle uninstall completion"""
        progress_dialog.destroy()
        
        # Clear state file
        if self.state_file.exists():
            self.state_file.unlink()
        
        # Clear config file
        if self.config_path.exists():
            self.config_path.unlink()
        
        # Show completion dialog
        complete = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="✅ Uninstall Complete"
        )
        complete.format_secondary_text(
            "Bentobox has been uninstalled.\n\n"
            "Your system has been reset to near-default Ubuntu state.\n\n"
            "What was removed:\n"
            "• Desktop applications (Cursor, VS Code, Chrome, etc.)\n"
            "• Terminal tools (btop, fastfetch, lazygit, etc.)\n"
            "• Docker containers (Portainer, OpenWebUI, Ollama)\n"
            "• GNOME theme, fonts, and customizations\n"
            "• Custom configurations and state files\n"
            "• Repository sources and GPG keys\n\n"
            "You may want to:\n"
            "• Reboot your system\n"
            "• Run 'sudo apt autoremove' to clean up packages\n"
            "• Manually remove ~/.local/share/omakub if desired"
        )
        complete.run()
        complete.destroy()
        
        # Refresh status view
        self.update_status_view()
    
    def on_uninstall_error(self, progress_dialog, error_msg):
        """Handle uninstall error"""
        progress_dialog.destroy()
        
        error = Gtk.MessageDialog(
            transient_for=self.window,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text="Uninstall Error"
        )
        error.format_secondary_text(
            f"An error occurred during uninstall:\n\n{error_msg}\n\n"
            "Some components may not have been removed.\n"
            "You may need to manually clean up your system."
        )
        error.run()
        error.destroy()
    
    def on_start_install(self, button):
        """Start the installation process"""
        # Save config first
        self.save_config()
        
        # Switch to Install tab (tab index 5)
        self.notebook.set_current_page(5)
        
        # Update info label
        self.install_info_label.set_markup("<b>🚀 Installation in progress...</b>")
        
        # Disable install button
        self.install_btn.set_sensitive(False)
        self.install_btn.set_label("⏳ Installing...")
        
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
        
        # Update info label to show completion
        self.install_info_label.set_markup(
            "<big><b>✅ Installation Complete!</b></big>\n\n"
            "Check the Status tab for details about installed components."
        )
        
        # Refresh status
        self.state = self.load_state()
        self.update_status_view()
    
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
    
    # Suppress GTK warnings about markup parsing (non-fatal)
    import warnings
    warnings.filterwarnings("ignore")
    os.environ['G_MESSAGES_DEBUG'] = ''
    
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

