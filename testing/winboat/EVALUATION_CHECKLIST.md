# WinBoat Evaluation Checklist

Quick reference checklist for evaluating WinBoat for bentobox inclusion.

## Pre-Testing Setup
- [ ] Clean Ubuntu 24.04 VM or test machine available
- [ ] 16GB+ RAM on test machine
- [ ] 100GB+ free disk space
- [ ] Virtualization enabled in BIOS
- [ ] Stable internet connection
- [ ] Test applications available (trials/free versions)

## Phase 1: Quick Assessment (1-2 hours)
- [ ] Visit official website and review documentation
- [ ] Check GitHub for issues, activity, last commit date
- [ ] Review community engagement (Discord, forums)
- [ ] Identify any major red flags or concerns
- [ ] Verify license compatibility (MIT ✓)
- [ ] Check system requirements vs. typical bentobox user

**Decision Point**: Proceed to full testing? ☐ Yes ☐ No

## Phase 2: Installation Testing (2-4 hours)
- [ ] Install prerequisites (QEMU, Docker, libvirt)
- [ ] Download WinBoat (record download method/URL)
- [ ] Install WinBoat application
- [ ] Initial launch and interface check
- [ ] Windows VM installation process
- [ ] Record installation time and complexity

**Success Criteria**: Installation completes without major issues

## Phase 3: Core Functionality (4-6 hours)
- [ ] Windows desktop loads and is responsive
- [ ] Install basic applications (browser, Office)
- [ ] Test filesystem integration (Linux ↔ Windows)
- [ ] Test clipboard integration
- [ ] Test window management (minimize, maximize, Alt+Tab)
- [ ] Test audio playback
- [ ] Test network connectivity

**Success Criteria**: All core functions work acceptably

## Phase 4: Performance & Stability (4-8 hours)
- [ ] Monitor resource usage (RAM, CPU, disk)
- [ ] Test with multiple apps open
- [ ] Run for extended period (4+ hours)
- [ ] Test suspend/resume cycles
- [ ] Test VM restart after crash simulation
- [ ] Measure application launch times
- [ ] Evaluate RDP responsiveness

**Success Criteria**: Acceptable performance, no crashes

## Phase 5: Advanced Features (2-4 hours)
- [ ] USB passthrough testing (if applicable)
- [ ] Multi-monitor support (if applicable)
- [ ] Large file transfer testing
- [ ] Professional app testing (Adobe/Office trials)
- [ ] VM snapshot/backup (if available)

**Success Criteria**: Advanced features work or fail gracefully

## Phase 6: Uninstallation (1 hour)
- [ ] Stop all WinBoat services
- [ ] Uninstall WinBoat
- [ ] Verify cleanup (Docker containers, volumes)
- [ ] Check for orphaned files
- [ ] Verify disk space reclaimed

**Success Criteria**: Clean removal, no leftovers

## Decision Matrix

### Include in Bentobox: ✓
Must meet ALL of these:
- [ ] Installs successfully on Ubuntu 24.04
- [ ] Core functionality works reliably
- [ ] Performance is acceptable for intended use cases
- [ ] Uninstalls cleanly
- [ ] Documentation is adequate
- [ ] Active development/community support
- [ ] No critical security issues
- [ ] Provides clear value over alternatives (WINE)

### Include with Warnings: ⚠️
Meet MOST but not all, AND:
- [ ] Issues are clearly documented
- [ ] Workarounds are available
- [ ] Beta status is acceptable to users
- [ ] Easy to uninstall if not suitable

### Do Not Include: ✗
Any of these:
- [ ] Installation fails consistently
- [ ] Core functionality broken
- [ ] Unacceptable performance
- [ ] Security concerns
- [ ] Abandoned project
- [ ] No clear value proposition
- [ ] Too complex for target users

## Final Recommendation

**Date Evaluated**: ________________  
**Evaluator**: ________________  
**WinBoat Version**: ________________

**Recommendation**: ☐ Include ☐ Include with Warnings ☐ Delay ☐ Exclude

**Rationale**:
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________

**Key Strengths**:
1. _____________________________________________________________________________
2. _____________________________________________________________________________
3. _____________________________________________________________________________

**Key Weaknesses**:
1. _____________________________________________________________________________
2. _____________________________________________________________________________
3. _____________________________________________________________________________

**Action Items**:
- [ ] _____________________________________________________________________________
- [ ] _____________________________________________________________________________
- [ ] _____________________________________________________________________________

**Follow-up Date**: ________________

---

## Notes Section

Use this space for any additional observations, concerns, or recommendations:

_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________

