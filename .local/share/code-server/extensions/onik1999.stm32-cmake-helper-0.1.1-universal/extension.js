const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { execSync } = require("child_process");
const os = require("os");

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('STM32 CMake Helper extension is now active!');

    let disposable = vscode.commands.registerCommand('stm32.initProject', async function () {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders) {
            vscode.window.showErrorMessage('Open a project folder first.');
            return;
        }

        const rootPath = workspaceFolders[0].uri.fsPath;

        try {
            await initializeProject(rootPath);
            vscode.window.showInformationMessage('STM32 project initialized successfully!');
        } catch (err) {
            vscode.window.showErrorMessage(`STM32 initializer failed: ${err.message}`);
        }
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};

/**
 * Main initializer function
 * @param {string} rootPath
 */
async function initializeProject(rootPath) {
    createBuildFolders(rootPath);
    createTasksJson(rootPath);
    createLaunchJson(rootPath);
    createClangdFile(rootPath);

    // Use spawn cross-platform
    await runCommand('cmake', ['--preset', 'Debug'], rootPath);
    await runCommand('cmake', ['--preset', 'Release'], rootPath);
}

/**
 * Create Debug and Release build folders
 * @param {string} rootPath
 */
function createBuildFolders(rootPath) {
    fs.mkdirSync(path.join(rootPath, 'build', 'Debug'), { recursive: true });
    fs.mkdirSync(path.join(rootPath, 'build', 'Release'), { recursive: true });
}

/**
 * Generate tasks.json for VSCode
 * @param {string} rootPath
 */
function createTasksJson(rootPath) {
    const vscodeDir = path.join(rootPath, '.vscode');
    fs.mkdirSync(vscodeDir, { recursive: true });

    const tasks = {
        version: "2.0.0",
        tasks: [
            { label: "build-debug", type: "shell", command: "cmake", args: ["--build", "--preset", "Debug"], problemMatcher: ["$gcc"] },
            { label: "build-release", type: "shell", command: "cmake", args: ["--build", "--preset", "Release"], problemMatcher: ["$gcc"] }
        ]
    };

    fs.writeFileSync(path.join(vscodeDir, 'tasks.json'), JSON.stringify(tasks, null, 2));
}

/**
 * Generate launch.json for VSCode debugging
 * @param {string} rootPath
 */
function createLaunchJson(rootPath) {
    const vscodeDir = path.join(rootPath, '.vscode');
    fs.mkdirSync(vscodeDir, { recursive: true });
	
    const elfName = detectProjectElfName(rootPath);
    const mcuName = detectOpenOcdTarget(rootPath);
    const gdb = findGdb();

    const launch = {
        version: "0.2.0",
        configurations: [
            {
                name: "STM32 Debug",
                type: "cortex-debug",
                request: "launch",
                gdbPath: gdb,
                servertype: "openocd",
                executable: path.join("${workspaceFolder}", 'build', 'Debug', elfName),
                cwd: "${workspaceFolder}",
                preLaunchTask:"build-debug",
                runToEntryPoint: "main",
                configFiles: [
                    "interface/stlink-v2.cfg",
                    mcuName
                ]
            },
            {
                name: "STM32 Release",
                type: "cortex-debug",
                request: "launch",
                gdbPath: gdb,
                servertype: "openocd",
                executable: path.join("${workspaceFolder}", 'build', 'Release', elfName),
                cwd: "${workspaceFolder}",
                preLaunchTask:"build-release",
                runToEntryPoint: "main",
                configFiles: [
                    "interface/stlink-v2.cfg",
                    mcuName
                ]
            }
        ]
    };

    fs.writeFileSync(path.join(vscodeDir, 'launch.json'), JSON.stringify(launch, null, 2));
}

/**
 * Generate .clangd file for clangd integration
 * @param {string} rootPath
 */
function createClangdFile(rootPath) {
    const clangdContent = `
CompileFlags:
  CompilationDatabase: build/Debug
Diagnostics:
  Suppress:
    - unused-includes
`;

    fs.writeFileSync(path.join(rootPath, '.clangd'), clangdContent);
}

/**
 * Run shell command cross-platform
 * @param {string} command
 * @param {Array<string>} args
 * @param {string} cwd
 */
function runCommand(command, args, cwd) {
    return new Promise((resolve, reject) => {
        const proc = spawn(command, args, { cwd, shell: true });

        proc.stdout.on('data', data => console.log(data.toString()));
        proc.stderr.on('data', data => console.error(data.toString()));

        proc.on('close', code => {
            if (code !== 0) reject(new Error(`Command failed: ${command} ${args.join(' ')}`));
            else resolve();
        });
    });
}

/**
 * Detects project name from CMakeLists.txt
 */
function detectProjectElfName(rootPath) {
    const cmakeFile = path.join(rootPath, 'CMakeLists.txt');

    if (!fs.existsSync(cmakeFile)) {
        console.warn('CMakeLists.txt not found. Using default ELF name "firmware.elf".');
        return 'firmware.elf';
    }

    const content = fs.readFileSync(cmakeFile, 'utf8');
    const match = content.match(/set\s*\(\s*CMAKE_PROJECT_NAME\s+([^\s\)]+)\s*\)/i);

    return match && match[1] ? match[1] + '.elf' : 'firmware.elf';
}

/**
 * Detects OpenOCD target cfg from STM32Cube .ioc file (key=value)
 */
function detectOpenOcdTarget(rootPath) {
    const files = fs.readdirSync(rootPath);
    const iocFile = files.find(f => f.endsWith('.ioc'));

    if (!iocFile) {
        console.warn('No .ioc file found — using default stm32f1x.cfg');
        return 'target/stm32f1x.cfg';
    }

    const content = fs.readFileSync(path.join(rootPath, iocFile), 'utf8');
    let mcuFamily = null;

    content.split(/\r?\n/).forEach(line => {
        line = line.trim();
        if (line.startsWith('Mcu.Family=')) mcuFamily = line.split('=')[1].toUpperCase();
    });

    if (!mcuFamily) {
        console.warn('Mcu.Family not found in .ioc — using default stm32f1x.cfg');
        return 'target/stm32f1x.cfg';
    }

    const familyMap = {
        'STM32F0': 'target/stm32f0x.cfg',
        'STM32F1': 'target/stm32f1x.cfg',
        'STM32F2': 'target/stm32f2x.cfg',
        'STM32F3': 'target/stm32f3x.cfg',
        'STM32F4': 'target/stm32f4x.cfg',
        'STM32F7': 'target/stm32f7x.cfg',
        'STM32G0': 'target/stm32g0x.cfg',
        'STM32G4': 'target/stm32g4x.cfg',
        'STM32H7': 'target/stm32h7x.cfg',
        'STM32L0': 'target/stm32l0.cfg',
        'STM32L1': 'target/stm32l1.cfg',
        'STM32L4': 'target/stm32l4x.cfg',
        'STM32L5': 'target/stm32l5x.cfg',
        'STM32WB': 'target/stm32wbx.cfg',
        'STM32WL': 'target/stm32wlx.cfg'
    };

    return familyMap[mcuFamily] || 'target/stm32f1x.cfg';
}





function findGdb() {
    const isWindows = os.platform() === "win32";

    const candidates = isWindows
        ? ["arm-none-eabi-gdb.exe", "gdb-multiarch.exe"]
        : ["arm-none-eabi-gdb", "gdb-multiarch"];

    for (const cmd of candidates) {
        try {
            const result = execSync(
                isWindows ? `where ${cmd}` : `which ${cmd}`,
                { stdio: ["ignore", "pipe", "ignore"] }
            )
                .toString()
                .split("\n")[0]
                .trim();

            if (result) {
                return result;
            }
        } catch (e) {
            // Not found, try next
        }
    }

    return null;
}
