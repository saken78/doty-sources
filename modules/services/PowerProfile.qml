pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.theme

Singleton {
    id: root
    property var availableProfiles: []
    property string currentProfile: ""
    property bool isAvailable: false
    property bool isChangingProfile: false
    property string lastError: ""

    signal profileChanged(string profile)
    signal profileChangeFailed(string error)
    signal profileChanging(string profile)

    Component.onCompleted: {
        console.info("PowerProfile: Initializing...");
        checkProc.running = true;
    }

    Process {
        id: checkProc
        command: ["/sbin/tlp", "--version"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const output = data.trim();
                if (output && output.length > 0) {
                    console.info("PowerProfile: " + output);
                }
            }
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                console.info("PowerProfile: ✓ TLP terdeteksi");
                isAvailable = true;
                lastError = "";
                availableProfiles = ["power-saver", "balanced", "performance"];
                console.info("PowerProfile: Available profiles:", availableProfiles);
                Qt.callLater(() => {
                    getProc.running = true;
                });
            } else {
                console.warn("PowerProfile: ✗ TLP tidak terdeteksi");
                isAvailable = false;
                lastError = "TLP tidak ditemukan di /sbin/tlp";
            }
        }
    }

    Process {
        id: getProc
        command: ["bash", "-c", "/sbin/tlp-stat -p 2>/dev/null | grep -i 'Active profile' | head -1"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (!line)
                    return;

                console.info("PowerProfile: tlp-stat output:", line);
                let profile = "";

                if (line.includes("power-saver") || line.includes("powersaver")) {
                    profile = "power-saver";
                } else if (line.includes("balanced")) {
                    profile = "balanced";
                } else if (line.includes("performance")) {
                    profile = "performance";
                }

                if (profile && currentProfile !== profile) {
                    currentProfile = profile;
                    console.info("PowerProfile: ✓ Current profile set to:", profile);
                    profileChanged(profile);
                }
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("PowerProfile: Failed to get current profile");
            }
        }
    }

    Process {
        id: setProc
        running: false
        stdout: SplitParser {}
        stderr: SplitParser {
            onRead: data => {
                const err = data.trim();
                if (err && err.length > 0) {
                    console.warn("PowerProfile: Error:", err);
                }
            }
        }
        onExited: exitCode => {
            isChangingProfile = false;

            if (exitCode === 0) {
                console.info("PowerProfile: ✓ Profile changed successfully");
                lastError = "";
                Qt.callLater(() => {
                    getProc.running = true;
                });
            } else {
                let error = "";
                if (exitCode === 1) {
                    error = "Permission denied. Setup NOPASSWD atau run dengan sudo";
                } else if (exitCode === 127) {
                    error = "TLP command not found";
                } else {
                    error = "Gagal mengubah profile (exit code: " + exitCode + ")";
                }
                console.warn("PowerProfile: " + error);
                lastError = error;
                profileChangeFailed(error);
            }
        }
    }

    function setProfile(profileName) {
        console.info("PowerProfile: setProfile called:", profileName);

        if (!isAvailable) {
            const error = "TLP tidak tersedia";
            console.warn("PowerProfile:", error);
            lastError = error;
            profileChangeFailed(error);
            return;
        }

        if (isChangingProfile) {
            console.warn("PowerProfile: Already changing, please wait");
            return;
        }

        let found = false;
        for (let i = 0; i < availableProfiles.length; i++) {
            if (availableProfiles[i] === profileName) {
                found = true;
                break;
            }
        }

        if (!found) {
            const error = "Profile tidak tersedia: " + profileName;
            console.warn("PowerProfile:", error);
            lastError = error;
            profileChangeFailed(error);
            return;
        }

        console.info("PowerProfile: Changing profile to:", profileName);
        isChangingProfile = true;
        profileChanging(profileName);

        // UPDATE LANGSUNG UI
        currentProfile = profileName;
        console.info("PowerProfile: ✓ UI updated to:", profileName);

        let cmd = [];
        if (profileName === "performance") {
            cmd = ["sudo", "/sbin/tlp", "performance"];
        } else if (profileName === "balanced") {
            cmd = ["sudo", "/sbin/tlp", "balanced"];
        } else if (profileName === "power-saver") {
            cmd = ["sudo", "/sbin/tlp", "power-saver"];
        }

        console.info("PowerProfile: Executing:", cmd.join(" "));
        setProc.command = cmd;
        setProc.running = true;
    }

    function updateCurrentProfile() {
        if (isAvailable) {
            console.info("PowerProfile: Refreshing current profile...");
            getProc.running = true;
        }
    }

    function updateAvailableProfiles() {
        console.info("PowerProfile: Available profiles:", availableProfiles);
    }

    function getProfileIcon(profileName) {
        if (profileName === "power-saver")
            return Icons.powerSave;
        if (profileName === "balanced")
            return Icons.balanced;
        if (profileName === "performance")
            return Icons.performance;
        return Icons.balanced;
    }

    function getProfileDisplayName(profileName) {
        if (profileName === "power-saver")
            return "Saver";
        if (profileName === "balanced")
            return "Code";
        if (profileName === "performance")
            return "Perf";
        return profileName;
    }

    function getProfileDescription(profileName) {
        if (profileName === "power-saver") {
            return "🔋 Hemat daya maksimal";
        } else if (profileName === "balanced") {
            return "⚖️ Keseimbangan performa & daya";
        } else if (profileName === "performance") {
            return "⚡ Performa maksimal";
        }
        return "";
    }
}
